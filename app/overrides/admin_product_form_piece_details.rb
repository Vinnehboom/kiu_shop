module AdminProductFormPieceDetails
  Deface::Override.new(
    virtual_path: 'spree/admin/products/_form',
    name: 'admin-product-form-piece-details',
    insert_bottom: "[data-hook='admin_product_form_additional_fields']",
    text: "<%= render 'spree/admin/products/piece_details', f: f %>"
  )
end
