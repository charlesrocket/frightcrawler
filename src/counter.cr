# Tracks validated data's types and count.
class Counter
  @@total_count : UInt16 = 0
  @@unique_count : UInt16 = 0

  @@legal : UInt16 = 0
  @@not_legal : UInt16 = 0
  @@restricted : UInt16 = 0
  @@banned : UInt16 = 0

  @@common : UInt16 = 0
  @@uncommon : UInt16 = 0
  @@rare : UInt16 = 0
  @@special : UInt16 = 0
  @@mythic : UInt16 = 0
  @@bonus : UInt16 = 0
  @@foil : UInt16 = 0
  @@efoil : UInt16 = 0

  # Prints out validation summary.
  def self.output : Nil
    puts "\n  Legal: #{get_legal.colorize(:green)}"
    puts "  Not legal: #{get_not_legal.colorize(:red)}"
    puts "  Restricted: #{get_restricted.colorize(:blue)}"
    puts "  Banned: #{get_banned.colorize(:red)}"
    puts "\n  | ▲ #{get_foil}"
    puts "  | ◭ #{get_efoil}"
    puts "\n  | C #{get_common.colorize(:white)}"
    puts "  | U #{get_uncommon.colorize(:cyan)}"
    puts "  | R #{get_rare.colorize(:light_yellow)}"
    puts "  | S #{get_special.colorize(:yellow)}"
    puts "  | M #{get_mythic.colorize(:magenta)}"
    puts "  | B #{get_bonus.colorize(:light_blue)}"
    puts "\n  Unique/total processed: #{get_unique}/#{get_total}"
    puts "  Elapsed time: #{T2 - T1}"
    puts "\nDONE"
  end

  def self.total(x) : UInt16
    @@total_count += x
  end

  def self.unique : UInt16
    @@unique_count += 1
  end

  def self.legal(x) : UInt16
    @@legal += x
  end

  def self.not_legal(x) : UInt16
    @@not_legal += x
  end

  def self.restricted(x) : UInt16
    @@restricted += x
  end

  def self.banned(x) : UInt16
    @@banned += x
  end

  def self.common(x) : UInt16
    @@common += x
  end

  def self.uncommon(x) : UInt16
    @@uncommon += x
  end

  def self.rare(x) : UInt16
    @@rare += x
  end

  def self.special(x) : UInt16
    @@special += x
  end

  def self.mythic(x) : UInt16
    @@mythic += x
  end

  def self.bonus(x) : UInt16
    @@bonus += x
  end

  def self.foil(x) : UInt16
    @@foil += x
  end

  def self.efoil(x) : UInt16
    @@efoil += x
  end

  def self.get_total : UInt16
    @@total_count
  end

  def self.get_unique : UInt16
    @@unique_count
  end

  def self.get_legal : UInt16
    @@legal
  end

  def self.get_not_legal : UInt16
    @@not_legal
  end

  def self.get_restricted : UInt16
    @@restricted
  end

  def self.get_banned : UInt16
    @@banned
  end

  def self.get_common : UInt16
    @@common
  end

  def self.get_uncommon : UInt16
    @@uncommon
  end

  def self.get_rare : UInt16
    @@rare
  end

  def self.get_special : UInt16
    @@special
  end

  def self.get_mythic : UInt16
    @@mythic
  end

  def self.get_bonus : UInt16
    @@bonus
  end

  def self.get_foil : UInt16
    @@foil
  end

  def self.get_efoil : UInt16
    @@efoil
  end

  # Resets `Counter`.
  def self.reset : Nil
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
  end
end
