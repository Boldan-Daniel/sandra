class FieldPicker
  def initialize(presenter)
    @presenter = presenter
  end

  def pick
    build_fields
    @presenter
  end

  private

  def build_fields
    fields.each do |field|
      target = @presenter.respond_to?(field) ? @presenter : @presenter.object
      @presenter.data[field] = target.send(field) if target
    end
  end

  def fields
    @fields ||= validate_fields
  end

  def validate_fields
    return pickable if @presenter.params[:fields].nil? || @presenter.params[:fields].blank?

    fields = @presenter.params[:fields].split(',')

    fields.each do |field|
      error!(field) unless pickable.include?(field)
    end

    fields
  end

  def pickable
    @pickable ||= @presenter.class.build_attributes
  end

  def error!(field)
    build_attributes = pickable.join(',')
    raise RepresentationBuilderError.new("fields=#{field}"),
        "Invalid Field Pick. Allowed fields: #{build_attributes}"
  end
end