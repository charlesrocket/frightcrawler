# Tracks validated data's types and count.
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

  # Prints out validation summary.
  def self.output : Nil
    puts "\n  Legal: #{Counter.get_legal.colorize(:green)}"
    puts "  Not legal: #{Counter.get_not_legal.colorize(:red)}"
    puts "  Restricted: #{Counter.get_restricted.colorize(:blue)}"
    puts "  Banned: #{Counter.get_banned.colorize(:red)}"
    puts "\n  | ▲ #{Counter.get_foil}"
    puts "  | ◭ #{Counter.get_efoil}"
    puts "\n  | C #{Counter.get_common.colorize(:white)}"
    puts "  | U #{Counter.get_uncommon.colorize(:cyan)}"
    puts "  | R #{Counter.get_rare.colorize(:light_yellow)}"
    puts "  | S #{Counter.get_special.colorize(:yellow)}"
    puts "  | M #{Counter.get_mythic.colorize(:magenta)}"
    puts "  | B #{Counter.get_bonus.colorize(:light_blue)}"
    puts "\n  Unique/total processed: #{Counter.get_unique}/#{Counter.get_total}"
    puts "  Elapsed time: #{T2 - T1}"
    puts "\nDONE"
  end

  def self.total(x) : Int16
    @@total_count += x
  end

  def self.unique : Int16
    @@unique_count += 1
  end

  def self.legal(x) : Int16
    @@legal += x
  end

  def self.not_legal(x) : Int16
    @@not_legal += x
  end

  def self.restricted(x) : Int16
    @@restricted += x
  end

  def self.banned(x) : Int16
    @@banned += x
  end

  def self.common(x) : Int16
    @@common += x
  end

  def self.uncommon(x) : Int16
    @@uncommon += x
  end

  def self.rare(x) : Int16
    @@rare += x
  end

  def self.special(x) : Int16
    @@special += x
  end

  def self.mythic(x) : Int16
    @@mythic += x
  end

  def self.bonus(x) : Int16
    @@bonus += x
  end

  def self.foil(x) : Int16
    @@foil += x
  end

  def self.efoil(x) : Int16
    @@efoil += x
  end

  def self.get_total : Int16
    @@total_count
  end

  def self.get_unique : Int16
    @@unique_count
  end

  def self.get_legal : Int16
    @@legal
  end

  def self.get_not_legal : Int16
    @@not_legal
  end

  def self.get_restricted : Int16
    @@restricted
  end

  def self.get_banned : Int16
    @@banned
  end

  def self.get_common : Int16
    @@common
  end

  def self.get_uncommon : Int16
    @@uncommon
  end

  def self.get_rare : Int16
    @@rare
  end

  def self.get_special : Int16
    @@special
  end

  def self.get_mythic : Int16
    @@mythic
  end

  def self.get_bonus : Int16
    @@bonus
  end

  def self.get_foil : Int16
    @@foil
  end

  def self.get_efoil : Int16
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
