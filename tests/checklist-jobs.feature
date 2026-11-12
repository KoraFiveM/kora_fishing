# Converted from the communitybot legacy tests by kora-qa-panel/scripts/convert-legacy.mjs.
# The """ block under each Scenario is the original test text, verbatim. Review before applying.
Feature: kora_fishing — Jobs

  @kora_fishing @checklist @checklist:kora_fishing:fishing-zones @cat:jobs
  Scenario: Fishing zone enter/exit notices
    """
    Checklist test: Carrying a pole walk into a dock zone (Sandy Bay or Vespucci piers): success notice; leaving shows 'left the fishing zone' and stops fishing.
    """
    Given I have 1 "fishing_pole"
    When I manually: go to the Sandy Bay or Vespucci pier dock fishing zone carrying the pole
    Then I should see a notification containing "You can use your fishing pole here"
    When I manually: walk out of the dock fishing zone
    Then I should see a notification containing "You have left the fishing zone"
    And I confirm: fishing stops

  @kora_fishing @checklist @checklist:kora_fishing:use-fishing-pole @cat:jobs
  Scenario: Use fishing pole in a zone
    """
    Checklist test: Use fishing_pole with a bait item inside a dock zone: rod prop and animation start, then the fishing minigame runs.
    """
    Given I have 1 "fishing_pole"
    And I have 1 "worm"
    When I manually: go to a dock fishing zone
    And I use a "fishing_pole"
    Then I confirm: a rod prop appears and the fishing animation starts
    And I confirm: the fishing minigame runs

  @kora_fishing @checklist @checklist:kora_fishing:pole-outside-zone @cat:jobs
  Scenario: Pole refused outside zone
    """
    Checklist test: Use a pole away from a zone or a pole not allowed there: 'You cannot use that pole here' error.
    """
    Given I have 1 "fishing_pole"
    When I use a "fishing_pole"
    Then I should see a notification containing "You cannot use that pole here"
    And I should see an error notification

  @kora_fishing @checklist @checklist:kora_fishing:fishing-minigame @cat:jobs
  Scenario: Fishing minigame and catch
    """
    Checklist test: Play the fishing minigame: success gives a fish matching the bait list, bait is consumed, fishing XP is added.
    """
    Given I have 1 "fishing_pole"
    And I have 1 "worm"
    When I manually: go to a dock fishing zone
    And I use a "fishing_pole"
    And I manually: play the fishing minigame and succeed
    Then I confirm: I receive a fish that matches the worm bait list
    And my "worm" count should have changed by -1
    And I confirm: my fishing XP increased

  @kora_fishing @checklist @checklist:kora_fishing:bait-levels @cat:jobs
  Scenario: Bait level requirements
    """
    Checklist test: Try worm (lvl 0), plug bait (15), soft plastic (30), spinner (45); higher baits need fishing level and give better fish.
    """
    Given I have 1 "fishing_pole"
    And I have 1 "worm"
    And I have 1 "plug_bait"
    And I have 1 "soft_plastic_bait"
    And I have 1 "spinner_bait"
    When I manually: go to a dock fishing zone
    And I manually: try fishing with worm, plug bait, soft plastic bait and spinner bait in turn
    Then I confirm: worm works at level 0, plug bait needs level 15, soft plastic bait level 30 and spinner bait level 45
    And I confirm: higher baits need the fishing level and give better fish

  @kora_fishing @checklist @checklist:kora_fishing:magnet-fishing @cat:jobs
  Scenario: Magnet fishing
    """
    Checklist test: With magnet_pole and a magnet (2/5/10/20lb) in a zone, play the minigame to pull up rusty junk; heavier magnets give rarer items.
    """
    Given I have 1 "magnet_pole"
    And I have 1 "magnet_2lb"
    And I have 1 "magnet_5lb"
    And I have 1 "magnet_10lb"
    And I have 1 "magnet_20lb"
    When I manually: go to a dock fishing zone
    And I use a "magnet_pole"
    And I manually: play the minigame with each magnet
    Then I confirm: I pull up rusty junk items
    And I confirm: heavier magnets give rarer items

  @kora_fishing @checklist @checklist:kora_fishing:stop-fishing @cat:jobs
  Scenario: Stop fishing / cleanup
    """
    Checklist test: Leave the zone or cancel while fishing: animation stops, the fishing rod prop is deleted and the server clears the session.
    """
    Given I have 1 "fishing_pole"
    And I have 1 "worm"
    When I manually: go to a dock fishing zone and start fishing
    And I manually: leave the zone or cancel while fishing
    Then I confirm: the fishing animation stops
    And I confirm: the fishing rod prop is deleted
    And I confirm: the server clears the fishing session

  @kora_fishing @checklist @checklist:kora_fishing:fishing-shop @cat:jobs
  Scenario: Fishing shop NPC
    """
    Checklist test: At the Paleto shop ped use 'Open Fishing Shop'; list shows items by level; Buy with an amount charges cash and gives items.
    """
    Given my cash balance is at least 500
    When I manually: go to the Paleto fishing shop ped
    And I select the "Open Fishing Shop" target option
    Then the "kora_fishing:shop" app opens
    And I confirm: the list shows items by level
    When I manually: choose an item, enter an amount and press Buy
    Then I confirm: my cash is charged and I receive the items

  @kora_fishing @checklist @checklist:kora_fishing:shop-level-lock @cat:jobs
  Scenario: Shop level restrictions
    """
    Checklist test: At a low fishing level, magnet pole/baits above your level are hidden or refused.
    """
    When I manually: go to the Paleto fishing shop ped
    And I select the "Open Fishing Shop" target option
    Then the "kora_fishing:shop" app opens
    And I confirm: at a low fishing level the magnet pole and baits above my level are hidden or refused

  @kora_fishing @checklist @checklist:kora_fishing:fish-buyer @cat:jobs
  Scenario: Fish buyer sells catch
    """
    Checklist test: At the Fish Buyer ped (Del Perro pier) use 'Open Buyer Menu', pick a fish and amount, Sell; cash is paid per fish price.
    """
    Given I have 3 "bass"
    When I manually: go to the Fish Buyer ped at Del Perro pier
    And I select the "Open Buyer Menu" target option
    Then the "kora_fishing:buyer" app opens
    When I manually: pick a fish and an amount and press Sell
    Then I confirm: my cash is increased by the fish price per fish sold

  @kora_fishing @checklist @checklist:kora_fishing:buyer-empty @cat:jobs
  Scenario: Buyer with nothing to sell
    """
    Checklist test: Open the buyer menu with no fish: 'You do not have any items to sell.' error.
    """
    Given I have no "bass"
    And I have no "blue_fish"
    And I have no "catfish"
    And I have no "flounder"
    And I have no "halibut"
    And I have no "reddrum"
    And I have no "salmon"
    And I have no "steelhead"
    And I have no "trout"
    And I have no "tuna"
    And I have no "white_bass"
    When I manually: go to the Fish Buyer ped at Del Perro pier
    And I select the "Open Buyer Menu" target option
    Then I should see a notification containing "You do not have any items to sell."
    And I should see an error notification

  @kora_fishing @checklist @checklist:kora_fishing:junk-breakdown @cat:jobs
  Scenario: Refine junk at breakdown spot
    """
    Checklist test: At the Breakdown Location (Davis area) use 'Open Refine Menu', refine rusty items; progress bar then random materials (rubber, scrap, copper...).
    """
    Given I have 1 "rusty_box"
    And I have 1 "rusty_tire"
    When I manually: go to the Breakdown Location in the Davis area
    And I select the "Open Refine Menu" target option
    Then the "kora_fishing:breakdown" app opens
    When I manually: refine the rusty items
    Then a progress bar should run
    And I confirm: I receive random materials such as rubber, scrap or copper

  @kora_fishing @checklist @checklist:kora_fishing:breakdown-empty @cat:jobs
  Scenario: Refine with no junk
    """
    Checklist test: Open Refine menu without junk items: 'You do not have any items to refine.' error.
    """
    Given I have no "rusty_box"
    And I have no "rusty_tire"
    And I have no "rusty_ak"
    And I have no "rusty_antenna"
    And I have no "rusty_bike"
    And I have no "rusty_chain"
    And I have no "rusty_motherboard"
    And I have no "rusty_pistol"
    And I have no "rusty_scanner"
    And I have no "rusty_scrap_metal"
    And I have no "rusty_shotgun"
    And I have no "rusty_sign"
    And I have no "rusty_usb"
    And I have no "rusty_wheelchair"
    When I manually: go to the Breakdown Location in the Davis area
    And I select the "Open Refine Menu" target option
    Then I should see a notification containing "You do not have any items to refine."
    And I should see an error notification

  @kora_fishing @checklist @checklist:kora_fishing:fishcatalog @cat:jobs
  Scenario: /fishcatalog panel
    """
    Checklist test: Run /fishcatalog: shows your fishing level, max level, fish, baits and poles; run again or close to dismiss.
    """
    When I run the command "/fishcatalog"
    Then the "qb-fishing:catalog" app opens
    And I confirm: the panel shows my fishing level, max level, fish, baits and poles
    When I run the command "/fishcatalog"
    Then I confirm: the panel is dismissed

  @kora_fishing @checklist @checklist:kora_fishing:fishing-blips @cat:jobs @manual
  Scenario: Fishing blips
    """
    Checklist test: Open the map: Fishing Shop, Fish Buyer, Breakdown Location and dock zone blips are shown (short range).
    """
    When I manually: open the map
    Then I confirm: Fishing Shop, Fish Buyer, Breakdown Location and dock zone blips are shown at short range
