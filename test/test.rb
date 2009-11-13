
#
# testing cloche
#
# Fri Nov 13 09:09:58 JST 2009
#

ROOT = File.join(File.dirname(__FILE__), '..')

require 'test/unit'
require File.join(ROOT, %w[ lib rufus cloche.rb ])

class ClocheTest < Test::Unit::TestCase

  def setup
    cloche_dir = File.join(ROOT, 'tcloche')
    FileUtils.rm_rf(cloche_dir) rescue nil
    @c = Rufus::Cloche.new(:dir => cloche_dir)
  end
  #def teardown
  #end

  def test_put

    r = @c.put({ '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })

    assert_nil r

    h = fetch('person', 'john')
    assert_equal '1', h['_rev']
  end

  def test_put_fail

    @c.put({ '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })
    r = @c.put({ '_id' => 'john', 'type' => 'person', 'eyes' => 'brown' })

    assert_equal '1', r['_rev']

    h = fetch('person', 'john')
    assert_equal 'green', h['eyes']
  end

  def test_delete_missing

    r = @c.delete({ '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })

    assert_nil r
  end

  def test_delete

    @c.put({ '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })

    r = @c.delete({ '_id' => 'john', 'type' => 'person', '_rev' => '1' })

    assert_nil r
    assert_equal false, File.exist?(File.join(ROOT, 'person', 'john'))
  end

  def test_delete_fail

    @c.put({ '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })

    r = @c.delete({ '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })

    assert_not_nil r
  end

  def test_get_many

    @c.put({ '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })
    @c.put({ '_id' => 'jami', 'type' => 'person', 'eyes' => 'blue' })
    @c.put({ '_id' => 'minehiko', 'type' => 'person', 'eyes' => 'brown' })
    @c.put({ '_id' => 'hiro', 'type' => 'person', 'eyes' => 'brown' })
    @c.put({ '_id' => 'chicko-chan', 'type' => 'animal', 'eyes' => 'black' })

    assert_equal(
      %w[ blue brown brown green ],
      @c.get_many('person').collect { |e| e['eyes'] }.sort)
  end

  def test_get_many_with_key_match

    @c.put({ '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })
    @c.put({ '_id' => 'jami', 'type' => 'person', 'eyes' => 'blue' })
    @c.put({ '_id' => 'minehiko', 'type' => 'person', 'eyes' => 'brown' })
    @c.put({ '_id' => 'hiro', 'type' => 'person', 'eyes' => 'brown' })
    @c.put({ '_id' => 'chicko-chan', 'type' => 'animal', 'eyes' => 'black' })

    assert_equal 2, @c.get_many('person', /^j/).size
  end

  protected

  def fetch (type, key)

    s = File.read(File.join(ROOT, 'tcloche', type, "#{key}.json"))
    Yajl::Parser.parse(s)
  end
end

