class EmbedPicker
  def initialize(presenter)
    @presenter = presenter
  end

  def embed
    return @presenter unless embeds.any?
    embeds.each { |valid_embed| build_embed(valid_embed) }
    @presenter
  end

  private

  def build_embed(valid_embed)
    embed_presenter = "#{relations[valid_embed].class_name}Presenter".constantize
    entity = @presenter.object.send(valid_embed)
    @presenter.data[valid_embed] = if relations[valid_embed].collection?
                               entity.order(:id).map do |embedded_entity|
                                 FieldPicker.new(embed_presenter.new(embedded_entity, {})).pick.data
                               end
                             else
                               entity ? FieldPicker.new(embed_presenter.new(entity, {})).pick.data : {}
                             end
  end

  def relations
    @relations ||= compute_relations
  end

  def compute_relations
    associations = @presenter.object.class.reflect_on_all_associations
    associations.each_with_object({}) do |r, hash|
      hash["#{r.name}"] = r
    end
  end

  def embeds
    @embeds ||= validate_embeds
  end

  def validate_embeds
    return [] if @presenter.params[:embed].nil? || @presenter.params[:embed].blank?

    param_embeds = @presenter.params[:embed].split(',')

    param_embeds.each do |param_embed|
      error!(param_embed) unless @presenter.class.relations.include?(param_embed)
    end

    param_embeds
  end

  def error!(param_embed)
    raise RepresentationBuilderError.new("embed=#{param_embed}"),
          "Invalid Embed. Allowed relations: #{@presenter.class.relations.join(',')}"
  end
end