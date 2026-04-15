@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Complaint'
@Metadata.allowExtensions: true

@UI: {
  headerInfo: { typeName: 'Complaint', typeNamePlural: 'Complaints', title: { type: #STANDARD, value: 'Description' } }
}
define root view entity Z_C_COMPLAINT
  provider contract transactional_query
  as projection on Z_I_Complaint
{
  @UI.facet: [ { id: 'Complaint', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'Complaint Details', position: 10 } ]

  @UI.hidden: true
  key ComplaintId,

  @UI: { lineItem:       [ { position: 10 } ],
         identification: [ { position: 10 } ] }
  @EndUserText.label: 'Complaint Description'
  Description,

  @UI: { lineItem:       [ { position: 20 } ],
         identification: [ { position: 20 } ] }
  @EndUserText.label: 'Customer Name'
  Customer,

  @UI: { lineItem:       [ { position: 30 }, { type: #FOR_ACTION, dataAction: 'generatePDF', label: 'Print PDF' } ],
         identification: [ { position: 30 }, { type: #FOR_ACTION, dataAction: 'generatePDF', label: 'Print PDF' } ] }
  @EndUserText.label: 'Status'
  Status,

  @UI.hidden: true
  CreatedAt
}
