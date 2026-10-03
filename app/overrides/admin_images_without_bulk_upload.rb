module AdminImagesWithoutBulkUpload
  Deface::Override.new(
    virtual_path: 'spree/admin/images/index',
    name: 'admin-images-without-bulk-upload',
    remove: 'fieldset.no-border-bottom'
  )
end
