module AdminImageFormRequiredAltText
  Deface::Override.new(
    virtual_path: 'spree/admin/images/_form',
    name: 'admin-image-form-required-alt-text',
    replace: "[data-hook='alt_text'] erb[loud]:contains('text_area')",
    text: "<%= f.text_area :alt, rows: 4, class: 'fullwidth', required: true %>"
  )
end
