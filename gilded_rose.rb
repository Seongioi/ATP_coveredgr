class GildedRose
  MAX_QUALITY = 50

  def initialize(items)
    @items = items
  end

  def update_quality
    @items.each do |item|
      if aged_brie?(item)
        increase_quality(item, 1)
      elsif backstage_pass?(item)
        case item.sell_in
          when -10..5
            increase_quality(item, 3)
          when 6..10
            increase_quality(item, 2)
          else
            increase_quality(item, 1)
        end
      end

      unless legendary?(item)
        item.sell_in = item.sell_in - 1
      end

      if generic?(item) && item.quality.positive?
        decrease_quality(item, 1)
        if item.sell_in.negative?
          decrease_quality(item, 1)
        end
      end

      if conjured?(item) && item.quality.positive?
        decrease_quality(item, 2)
        if item.sell_in.negative?
          decrease_quality(item, 2)
        end
      end

      if item.sell_in.negative?
        if backstage_pass?(item)
          item.quality = 0
        elsif aged_brie?(item)
          increase_quality(item, 1)
        end
      end
    end
  end

  private

  def quality_maxed(item)
    item.quality >= MAX_QUALITY
  end

  def increase_quality(item, increase_value)
    item.quality = [MAX_QUALITY, item.quality + increase_value].min
  end

  def decrease_quality(item, decrease_value)
    item.quality = [0, item.quality - decrease_value].max
  end

  def conjured?(item)
    item.name == 'Conjured'
  end


  def aged_brie?(item)
    item.name == 'Aged Brie'
  end

  def legendary?(item)
    item.name == 'Sulfuras, Hand of Ragnaros'
  end

  def backstage_pass?(item)
    item.name == 'Backstage passes to a TAFKAL80ETC concert'
  end

  def generic?(item)
    !aged_brie?(item) && !legendary?(item) && !backstage_pass?(item) && !conjured?(item)
  end
end

class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end
