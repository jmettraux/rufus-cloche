
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
    @c_dir = File.join(ROOT, 'tcloche')
    FileUtils.rm_rf(@c_dir) rescue nil
    @c = Rufus::Cloche.new(:dir => @c_dir)
  end
  #def teardown
  #end

  def test_put

    r = @c.put({ '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })

    assert_nil r

    h = fetch('person', 'john')
    assert_equal 0, h['_rev']
  end

  def test_depth

    @c.put({ '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })

    assert_equal(
      "test/../tcloche/person/hn/john.json",
      Dir[File.join(@c_dir, %w[ ** *.json ])].first)
  end

  def test_small_id

    r = @c.put({ '_id' => '0', 'type' => 'person', 'eyes' => 'green' })

    assert_nil r
  end

  def test_put_insufficient_doc

    assert_raise ArgumentError do
      @c.put({ '_id' => 'john', 'eyes' => 'shut' })
    end
  end

  def test_put_fail

    @c.put({ '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })
    r = @c.put({ '_id' => 'john', 'type' => 'person', 'eyes' => 'brown' })

    assert_equal 0, r['_rev']

    h = fetch('person', 'john')
    assert_equal 'green', h['eyes']
  end

  def test_re_put

    @c.put(
      { '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })

    r = @c.put(
      { '_id' => 'john', 'type' => 'person', 'eyes' => 'blue', '_rev' => 0 })

    assert_nil r

    h = fetch('person', 'john')
    assert_equal 1, h['_rev']
  end

  def test_delete_missing

    r = @c.delete({ '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })

    assert_not_nil r
  end

  def test_delete

    @c.put({ '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })

    r = @c.delete({ '_id' => 'john', 'type' => 'person', '_rev' => 0 })

    assert_nil r
    assert_equal false, File.exist?(File.join(ROOT, 'person', 'john'))
  end

  def test_delete_fail

    @c.put({ '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })

    r = @c.delete({ '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })

    assert_not_nil r
  end

  def test_get_many

    load_people

    assert_equal(
      %w[ blue brown brown green ],
      @c.get_many('person').collect { |e| e['eyes'] }.sort)
  end

  def test_get_many_with_key_match

    load_people

    assert_equal 2, @c.get_many('person', /^j/).size
  end

  def test_get_many_key_order

    load_people

    assert_equal(
      %w[ hiro jami john minehiko ],
      @c.get_many('person').collect { |e| e['_id'] })
  end

  def test_get_many_limit

    load_people

    assert_equal(
      %w[ hiro jami ],
      @c.get_many('person', nil, :limit => 2).collect { |e| e['_id'] })
  end

  def test_dot_id

    @c.put({ '_id' => 'something.0', 'type' => 'nothing', 'color' => 'blue' })

    #puts `tree -a tcloche`

    assert_equal 1, @c.get_many('nothing').size
  end

  protected

  def load_people

    @c.put({ '_id' => 'john', 'type' => 'person', 'eyes' => 'green' })
    @c.put({ '_id' => 'jami', 'type' => 'person', 'eyes' => 'blue' })
    @c.put({ '_id' => 'minehiko', 'type' => 'person', 'eyes' => 'brown' })
    @c.put({ '_id' => 'hiro', 'type' => 'person', 'eyes' => 'brown' })
    @c.put({ '_id' => 'chicko-chan', 'type' => 'animal', 'eyes' => 'black' })
  end

  def fetch (type, key)

    s = File.read(File.join(ROOT, 'tcloche', type, key[-2, 2], "#{key}.json"))
    Rufus::Cloche.json_decode(s)
  end
end

