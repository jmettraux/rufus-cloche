
require 'rubygems'
require 'lib/rufus/cloche'

CLO = Rufus::Cloche.new(:dir => 'cloche')

p $$

100.times do
  doc = CLO.get('person', 'john')
  sleep rand
  doc['pid'] = $$.to_s
  d = CLO.put(doc)
  puts d ? '* failure' : '. success'
  if d
    d['pid'] = $$.to_s
    d = CLO.put(d)
    puts d ? '    re_failure' : '    re_success'
  end
end

