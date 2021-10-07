class Counter
  @@total_count : Int16 = 0
  @@unique_count : Int16 = 0

  @@legal : Int16 = 0
  @@not_legal : Int16 = 0
  @@restricted : Int16 = 0
  @@banned : Int16 = 0

  @@common : Int16 = 0
  @@uncommon : Int16 = 0
  @@rare : Int16 = 0
  @@special : Int16 = 0
  @@mythic : Int16 = 0
  @@bonus : Int16 = 0
  @@foil : Int16 = 0
  @@efoil : Int16 = 0

  def self.total(x)
    @@total_count += x
  end

  def self.unique
    @@unique_count += 1
  end

  def self.legal(x)
    @@legal += x
  end

  def self.not_legal(x)
    @@not_legal += x
  end

  def self.restricted(x)
    @@restricted += x
  end

  def self.banned(x)
    @@banned += x
  end

  def self.common(x)
    @@common += x
  end

  def self.uncommon(x)
    @@uncommon += x
  end

  def self.rare(x)
    @@rare += x
  end

  def self.special(x)
    @@special += x
  end

  def self.mythic(x)
    @@mythic += x
  end

  def self.bonus(x)
    @@bonus += x
  end

  def self.foil(x)
    @@foil += x
  end

  def self.efoil(x)
    @@efoil += x
  end

  def self.get_total
    @@total_count
  end

  def self.get_unique
    @@unique_count
  end

  def self.get_legal
    @@legal
  end

  def self.get_not_legal
    @@not_legal
  end

  def self.get_restricted
    @@restricted
  end

  def self.get_banned
    @@banned
  end

  def self.get_common
    @@common
  end

  def self.get_uncommon
    @@uncommon
  end

  def self.get_rare
    @@rare
  end

  def self.get_special
    @@special
  end

  def self.get_mythic
    @@mythic
  end

  def self.get_bonus
    @@bonus
  end

  def self.get_foil
    @@foil
  end

  def self.get_efoil
    @@efoil
  end
end
