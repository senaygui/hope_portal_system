class AddFinanceApprovalStatusToDocumentRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :document_requests, :finance_approval_status, :string, default: 'Pending'
  end
end
