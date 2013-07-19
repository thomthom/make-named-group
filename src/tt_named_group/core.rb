#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'


#-------------------------------------------------------------------------------

module TT::Plugins::NamedGroup

  unless file_loaded?( __FILE__ )
    # Add menu items.
    m = UI.menu('Edit')
    m.add_item('Make Named Group') { self.named_group }
  end

  def self.named_group
    model = Sketchup.active_model
    sel = model.selection

    # Don't do anything if the selection is empty.
    return if sel.empty?

    # Build an array of the layer names.
    layers = model.layers.to_a.collect { |l| l.name }
    # Ask user for group name.
    list = ['', layers.join('|')]
    prompts = ['Group Name: ', 'Layer: ']
    defaults = [model.definitions.unique_name('Group#1'), model.active_layer.name]
    input = UI.inputbox(prompts, defaults, list, 'New Group')

    # Check if the user cancelled.
    return if input == false

    # Get data from result array into variables
    group_name, group_layer = input

    # Make it into one Undoable action
    model.start_operation('Make Named Group')

    # The add_group method can be buggy when you pass on entities to it's argument. But there's
    # no real options.
    group = model.active_entities.add_group(sel)
    name = model.definitions.unique_name(group_name)
    # We set the name we will see in the Entities window.
    group.name = name
    # We set the definition name as well. If you convert the group to a component, this is the
    # name it will get.
    group.entities.parent.name = name
    # Set group layer
    group.layer = model.layers[group_layer]

    # Select the new group
    sel.clear
    sel.add(group)

    model.commit_operation
  end

end # module

#-------------------------------------------------------------------------------

file_loaded( __FILE__ )

#-------------------------------------------------------------------------------
