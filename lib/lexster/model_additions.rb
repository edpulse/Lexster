module Lexster
  module ModelAdditions
    module ClassMethods
      attr_reader :lexster_config
      
      def lexster_config
        @lexster_config ||= Lexster::ModelConfig.new(self)
      end
      
      def lexsterable(options = {})
        # defaults
        lexster_config.auto_index = true
        lexster_config.enable_model_index = true # but the Lexster.enable_per_model_indexes is false by default. all models will be true only if the primary option is turned on.

        yield(lexster_config) if block_given?

        options.each do |key, value|
          raise "Lexster #{self.name} model options: No such option #{key}" unless lexster_config.respond_to?("#{key}=")
          lexster_config.send("#{key}=", value)
        end
      end

      def neo_model_index_name
        raise "Per Model index is not enabled. Nodes/Relationships are auto indexed with node_auto_index/relationship_auto_index" unless Lexster.config.enable_per_model_indexes || lexster_config.enable_model_index
        @index_name ||= "#{self.name.tableize}_index"
      end
    end
  
    module InstanceMethods
      def to_neo
        if self.class.lexster_config.stored_fields
          hash = self.class.lexster_config.stored_fields.inject({}) do |all, (field, block)|
            all[field] = if block
              instance_eval(&block)
            else
              self.send(field) rescue (raise "No field #{field} for #{self.class.name}")
            end
            
            all
          end

          hash.reject { |k, v| v.nil? }
        else
          {}
        end
      end

      def neo_save_after_model_save
        return unless self.class.lexster_config.auto_index
        neo_save
        true
      end

      def neo_save
        @_neo_destroyed = false
        @_neo_representation = _neo_save
      end

      alias neo_create neo_save
      alias neo_update neo_save

      def neo_destroy
        return if @_neo_destroyed
        @_neo_destroyed = true

        neo_representation = neo_find_by_id
        return unless neo_representation

        begin
          neo_representation.del
        rescue Neography::NodeNotFoundException => e
          Lexster::logger.info "Lexster#neo_destroy entity not found #{self.class.name} #{self.id}"
        end

        # Not working yet because Neography can't delete a node and all of its realtionships in a batch, and deleting a node with relationships results an error
        # if Lexster::Batch.current_batch
        #   Lexster::Batch.current_batch << [self.class.delete_command, neo_representation.neo_id]
        # else
        #   begin
        #     neo_representation.del
        #   rescue Neography::NodeNotFoundException => e
        #     Lexster::logger.info "Lexster#neo_destroy entity not found #{self.class.name} #{self.id}"
        #   end
        # end

        _reset_neo_representation

        true
      end

      def neo_unique_id
        "#{self.class.name}:#{self.id}"
      end

      protected
      def neo_properties_to_hash(*attribute_list)
        attribute_list.flatten.inject({}) { |all, property|
          all[property] = self.send(property)
          all
        }
      end

      private
      def _neo_representation
        @_neo_representation ||= neo_find_by_id || neo_save
      end

      def _reset_neo_representation
        @_neo_representation = nil
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods

      receiver.after_save :neo_save_after_model_save
      receiver.after_destroy :neo_destroy
    end
  end
end
