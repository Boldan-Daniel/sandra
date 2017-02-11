module Sandra
  class Serializer
    def initialize(data:, params:, actions:, options: {})
      @data = data
      @params = params
      @actions = actions
      @options = options
    end

    def to_json
      { data: build_data }
    end.to_json

    private

    def build_data
      if @data.respond_to?(:count)
        @data.map do |entity|
          presenter(entity).new(entity, @params, @options).build(@actions)
        end
      else
        presenter(@data).new(@data, @params, @options).build(@actions)
      end
    end

    def presenter(entity)
      @presenter ||= "#{entity.class}Presenter".constantize
    end


  end
end