@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Complaint View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity Z_I_Complaint
  as select from zcomplaint_tab
{
  key complaint_id as ComplaintId,
  description     as Description,
  customer        as Customer,
  status          as Status,
  created_at      as CreatedAt
}
