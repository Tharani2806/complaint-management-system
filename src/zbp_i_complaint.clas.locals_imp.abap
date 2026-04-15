" ==============================================================================
" 1. TRANSACTIONAL BUFFER (To hold data between Create/Delete and Save)
" ==============================================================================
CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA: mt_create TYPE TABLE OF zcomplaint_tab,
                mt_delete TYPE TABLE OF zcomplaint_tab. " Added delete buffer!
ENDCLASS.

CLASS lcl_buffer IMPLEMENTATION.
ENDCLASS.

" ==============================================================================
" 2. BEHAVIOR HANDLER (Handles UI Interaction like Create/Read/Delete)
" ==============================================================================
CLASS lhc_Complaint DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Complaint RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Complaint.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Complaint.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Complaint.

    METHODS read FOR READ
      IMPORTING keys FOR READ Complaint RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Complaint.

    METHODS generatePDF FOR MODIFY
      IMPORTING keys FOR ACTION Complaint~generatePDF RESULT result.
ENDCLASS.

CLASS lhc_Complaint IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    DATA: ls_db_record TYPE zcomplaint_tab.

    LOOP AT entities INTO DATA(ls_entity).
      ls_db_record-client      = sy-mandt.
      ls_db_record-description = ls_entity-Description.
      ls_db_record-customer    = ls_entity-Customer.
      ls_db_record-status      = ls_entity-Status.
      GET TIME STAMP FIELD ls_db_record-created_at.

      TRY.
          ls_db_record-complaint_id = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
      ENDTRY.

      APPEND ls_db_record TO lcl_buffer=>mt_create.

      INSERT VALUE #( %cid        = ls_entity-%cid
                      ComplaintId = ls_db_record-complaint_id ) INTO TABLE mapped-complaint.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
    DATA: ls_delete TYPE zcomplaint_tab.

    " Loop through the keys passed from Fiori and add to the delete buffer
    LOOP AT keys INTO DATA(ls_key).
      ls_delete-client       = sy-mandt.
      ls_delete-complaint_id = ls_key-ComplaintId.
      APPEND ls_delete TO lcl_buffer=>mt_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    IF keys IS NOT INITIAL.
      SELECT * FROM zcomplaint_tab
        FOR ALL ENTRIES IN @keys
        WHERE complaint_id = @keys-ComplaintId
        INTO TABLE @DATA(lt_complaint_db).

      result = CORRESPONDING #( lt_complaint_db MAPPING TO ENTITY ).
    ENDIF.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD generatePDF.
    READ ENTITIES OF Z_I_COMPLAINT IN LOCAL MODE
      ENTITY Complaint
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_complaints).

    CHECK lt_complaints IS NOT INITIAL.
    DATA(ls_complaint) = lt_complaints[ 1 ].

    result = VALUE #( FOR key IN keys ( %tky = key-%tky ) ).
  ENDMETHOD.

ENDCLASS.

" ==============================================================================
" 3. SAVER CLASS (Commits the buffer to the database)
" ==============================================================================
CLASS lsc_Z_I_COMPLAINT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_Z_I_COMPLAINT IMPLEMENTATION.
  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    " Insert new records
    IF lcl_buffer=>mt_create IS NOT INITIAL.
      INSERT zcomplaint_tab FROM TABLE @lcl_buffer=>mt_create.
    ENDIF.

    " Delete selected records!
    IF lcl_buffer=>mt_delete IS NOT INITIAL.
      DELETE zcomplaint_tab FROM TABLE @lcl_buffer=>mt_delete.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    " Clear both buffers
    CLEAR lcl_buffer=>mt_create.
    CLEAR lcl_buffer=>mt_delete.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
