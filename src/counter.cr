class Counter
  @@total_count = 0
  @@unique_count = 0
  @@legal_t = 0
  @@not_legal_t = 0
  @@restricted_t = 0
  @@banned_t = 0

  def self.add_total(x)
    @@total_count += x
  end

  def self.add_unique
    @@unique_count += 1
  end

  def self.legal(x)
    @@legal_t += x
  end

  def self.not_legal(x)
    @@not_legal_t += x
  end

  def self.restricted(x)
    @@restricted_t += x
  end

  def self.banned(x)
    @@banned_t += x
  end

  def self.get_total
    return @@total_count
  end

  def self.get_unique
    return @@unique_count
  end

  def self.get_legal
    return @@legal_t
  end

  def self.get_not_legal
    return @@not_legal_t
  end

  def self.get_restricted
    return @@restricted_t
  end

  def self.get_banned
    return @@banned_t
  end
end
