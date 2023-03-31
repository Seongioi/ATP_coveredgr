require File.join(File.dirname(__FILE__), 'gilded_rose')

describe GildedRose do
  describe '#update_quality' do
    context 'Conjured item' do
      it 'degrades in quality twice as fast' do
        items = [Item.new('Conjured', 20, 80)]
        GildedRose.new(items).update_quality
        expect(items[0].quality).to eq(78)
      end

      it 'degrades in quality twice as fast even when expired' do
        items = [
          Item.new('Conjured', 0, 80),
          Item.new('Generic item', 0, 80),
        ]
        GildedRose.new(items).update_quality
        expect(items[0].quality).to eq(76)
        expect(items[1].quality).to eq(78)
      end
    end

    context 'legendary item' do
      it 'quality does not decrease' do
        items = [Item.new('Sulfuras, Hand of Ragnaros', 20, 80)]
        GildedRose.new(items).update_quality
        expect(items[0].quality).to eq(80)
      end

      it 'never has to be sold' do
        items = [Item.new('Sulfuras, Hand of Ragnaros', 1, 80)]
        GildedRose.new(items).update_quality
        expect(items[0].sell_in).to eq(1)
      end

      it 'quality does not change past sell by date' do
        items = [Item.new('Sulfuras, Hand of Ragnaros', -1, 80)]
        GildedRose.new(items).update_quality
        expect(items[0].quality).to eq(80)
      end
    end

    [
      Item.new('generic item', 8, 10),
      Item.new('Aged Brie', 8, 10),
      Item.new('Backstage passes to a TAFKAL80ETC concert', 8, 10)
    ].each do |item|
      it "sell_in should decrease for item #{item.name}" do
        original_sell_in = item.sell_in
        GildedRose.new([item]).update_quality
        expect(item.sell_in).to eq(original_sell_in - 1)
      end
    end

    # TODO - convert next 3 tests to 1 parametrized test
    # there are several items whose Sellin decreases each update.. can we make it data driven?
    [
      Item.new('generic item', 0, 25),
      Item.new('Aged Brie', 0, 25),
      Item.new('Backstage passes to a TAFKAL80ETC concert', 0, 25)
    ].each do |item|
      it "sell in can be negetive for item #{item.name}" do
        GildedRose.new([item]).update_quality
        expect(item.sell_in).to eq(-1)
      end
    end

    it 'generic item quality decreases before sell by' do
      items = [Item.new('generic item', 5, 10)]
      GildedRose.new(items).update_quality
      expect(items[0].quality).to eq(9)
    end

    it 'generic item quality decreases twice as fast after sell by' do
      items = [Item.new('generic item', 0, 10)]
      GildedRose.new(items).update_quality
      expect(items[0].quality).to eq(8)
    end

    it 'generic item quality does not go negative' do
      items = [Item.new('generic item', 0, 0)]
      GildedRose.new(items).update_quality
      expect(0).to eq(items[0].quality)
    end

    # TODO: can all items which improve with and have cap be tested together?
    it 'brie quality increase before sell by' do
      items = [Item.new('Aged Brie', 5, 30)]
      GildedRose.new(items).update_quality
      expect(items[0].quality).to eq(31)
    end

    it 'brie quality has an upper limit' do
      items = [Item.new('Aged Brie', 5, 50)]
      GildedRose.new(items).update_quality
      expect(items[0].quality).to eq(50)
    end

    it 'backstage pass quality has an upper limit' do
      items = [Item.new('Backstage passes to a TAFKAL80ETC concert', 15, 50)]
      GildedRose.new(items).update_quality
      expect(items[0].quality).to eq(50)
    end

    it 'brie quality increases twice as fast after sell by' do
      items = [Item.new('Aged Brie', -1, 20)]
      GildedRose.new(items).update_quality
      expect(22).to eq(items[0].quality)
    end

    it 'brie quality has upper limit even when really old' do
      items = [Item.new('Aged Brie', -99, 50)]
      GildedRose.new(items).update_quality
      expect(50).to eq(items[0].quality)
    end

    it 'backstage pass quality increases each day when concert date is far off in future' do
      items = [Item.new('Backstage passes to a TAFKAL80ETC concert', 30, 23)]
      GildedRose.new(items).update_quality
      expect(24).to eq(items[0].quality)
    end

    it 'backstage pass quality increases more as concert date gets closer' do
      items = [Item.new('Backstage passes to a TAFKAL80ETC concert', 10, 40)]
      GildedRose.new(items).update_quality
      expect(42).to eq(items[0].quality)
    end

    it 'backstage pass quality increases much more when concert date is close' do
      items = [Item.new('Backstage passes to a TAFKAL80ETC concert', 5, 40)]
      GildedRose.new(items).update_quality
      expect(43).to eq(items[0].quality)
    end

    it 'backstage pass quality drops to zero when concert has passed' do
      items = [Item.new('Backstage passes to a TAFKAL80ETC concert', 0, 40)]
      GildedRose.new(items).update_quality
      expect(0).to eq(items[0].quality)
    end

    it 'backstage pass quality respects maximum value even when concert is near' do
      items = [Item.new('Backstage passes to a TAFKAL80ETC concert', 5, 49)]
      GildedRose.new(items).update_quality
      expect(50).to eq(items[0].quality)
    end

    it 'shop contains multiple items and all are updated' do
      items = [
        Item.new('Sulfuras, Hand of Ragnaros', 0, 80),
        Item.new('generic item', 10, 5)
      ]
      GildedRose.new(items).update_quality

      expect(items[0].sell_in).to eq(0)
      expect(items[1].sell_in).to eq(9)
    end
  end
end
