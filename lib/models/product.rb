class Product
  attr_reader :id, :name, :created_at

  def initialize(attributes)
    @id = attributes[:id]
    @name = attributes[:name]
    @created_at = attributes[:created_at]
  end

  def to_hash
    {
      id: @id,
      name: @name,
      created_at: @created_at&.iso8601
    }
  end
end
