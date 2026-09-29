module ShopSetup
  class DefaultPermissionSets
    def call
      core_permission_sets.each do |permission_set|
        Spree::PermissionSet.find_or_create_by!(set: permission_set.name) do |record|
          record.name = permission_set.name.demodulize
          record.privilege = permission_set.privilege
          record.category = permission_set.category
        end
      end
    end

    private

    def core_permission_sets
      core_permission_set_files.map { |file| Spree::PermissionSets.const_get(file.basename('.rb').to_s.camelize) }
                               .excluding(Spree::PermissionSets::Base)
    end

    def core_permission_set_files
      Spree::Core::Engine.root.glob('app/models/spree/permission_sets/*.rb')
    end
  end
end
