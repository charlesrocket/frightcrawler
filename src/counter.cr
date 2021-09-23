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

  def self.get_total
    return @@total_count
  end

  def self.get_unique
    return @@unique_count
  end

  def self.get_legal
    return @@legal
  end

  def self.get_not_legal
    return @@not_legal
  end

  def self.get_restricted
    return @@restricted
  end

  def self.get_banned
    return @@banned
  end

  def self.get_common
    return @@common
  end

  def self.get_uncommon
    return @@uncommon
  end

  def self.get_rare
    return @@rare
  end

  def self.get_special
    return @@special
  end

  def self.get_mythic
    return @@mythic
  end

  def self.get_bonus
    return @@bonus
  end
end
