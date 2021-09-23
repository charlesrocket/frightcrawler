class Counter
  @@total_count = 0
  @@unique_count = 0
  @@legal = 0
  @@not_legal = 0
  @@restricted = 0
  @@banned = 0

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
end
