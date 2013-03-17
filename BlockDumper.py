#!/usr/bin/python

# This is part of the Mer git-packaging suite
# 
# It provides a Dumper class which, as a side-effect, also modifies
# how yaml is dumped. It's not pretty but it works. Cleanup welcome.

import yaml
import yaml.constructor
import collections

class BlockDumper(yaml.Dumper):

    def increase_indent(self, flow=False, indentless=False):
        return super(BlockDumper, self).increase_indent(flow, False)

def construct_ordered_mapping(self, node, deep=False):
    if not isinstance(node, yaml.MappingNode):
        raise ConstructorError(None, None,
                "expected a mapping node, but found %s" % node.id,
                node.start_mark)
    mapping = collections.OrderedDict()
    for key_node, value_node in node.value:
        key = self.construct_object(key_node, deep=deep)
        if not isinstance(key, collections.Hashable):
            raise ConstructorError("while constructing a mapping", node.start_mark,
                    "found unhashable key", key_node.start_mark)
        value = self.construct_object(value_node, deep=deep)
        mapping[key] = value
    return mapping

yaml.constructor.BaseConstructor.construct_mapping = construct_ordered_mapping

def construct_yaml_map_with_ordered_dict(self, node):
    data = collections.OrderedDict()
    yield data
    value = self.construct_mapping(node)
    data.update(value)

yaml.constructor.Constructor.add_constructor(
        'tag:yaml.org,2002:map',
        construct_yaml_map_with_ordered_dict)

def represent_ordered_mapping(self, tag, mapping, flow_style=None):
    value = []
    node = yaml.MappingNode(tag, value, flow_style=flow_style)
    if self.alias_key is not None:
        self.represented_objects[self.alias_key] = node
    best_style = True
    if hasattr(mapping, 'items'):
        mapping = list(mapping.items())
    for item_key, item_value in mapping:
        node_key = self.represent_data(item_key)
        node_value = self.represent_data(item_value)
        if not (isinstance(node_key, yaml.ScalarNode) and not node_key.style):
            best_style = False
        if not (isinstance(node_value, yaml.ScalarNode) and not node_value.style):
            best_style = False
        value.append((node_key, node_value))
    if flow_style is None:
        if self.default_flow_style is not None:
            node.flow_style = self.default_flow_style
        else:
            node.flow_style = best_style
    return node

yaml.representer.BaseRepresenter.represent_mapping = represent_ordered_mapping

yaml.representer.Representer.add_representer(collections.OrderedDict,
        yaml.representer.SafeRepresenter.represent_dict)

# Nice trick to ensure any scalar containing a \n is output in block (|) format
def mystr_presenter(dumper, data):
    tag = None
    style = None
    if "\n" in data:
        style='|'
    try:
        data = unicode(data, 'ascii')
        tag = u'tag:yaml.org,2002:str'
    except UnicodeDecodeError:
        try:
            data = unicode(data, 'utf-8')
            tag = u'tag:yaml.org,2002:python/str'
        except UnicodeDecodeError:
            data = data.encode('base64')
            tag = u'tag:yaml.org,2002:binary'
            style = '|'
    return dumper.represent_scalar(tag, data, style=style)

yaml.add_representer(str, mystr_presenter)

