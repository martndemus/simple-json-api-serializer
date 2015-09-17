module TestObjects
  Address = Struct.new(:id, :street, :number, :zip_code, :city)
  Article = Struct.new(:id, :author_id)
  Car     = Struct.new(:number_plate)
  Duck    = Struct.new(:id)
  Foo     = Struct.new(:id, :bars)
  Post    = Struct.new(:id, :comment_ids)
end
