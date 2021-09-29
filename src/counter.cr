class Counter
  @@total_count = 0
  @@unique_count = 0

  @@legal = 0
  @@not_legal = 0
  @@restricted = 0
  @@banned = 0

  @@common = 0
  @@uncommon = 0
  @@rare = 0
  @@special = 0
  @@mythic = 0
  @@bonus = 0

  @@foil = 0
  @@efoil = 0

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
