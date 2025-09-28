module challenge::hero;

use std::string::String;

// ========= STRUCTS =========
public struct Hero has key, store {
    id: UID,
    name: String,
    image_url: String,
    power: u64,
}

public struct HeroMetadata has key, store {
    id: UID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

#[allow(lint(self_transfer))]
public fun create_hero(name: String, image_url: String, power: u64, ctx: &mut TxContext) {

    // Hero struct creation
    let hero  = Hero {
        id: object::new(ctx),
        name,
        image_url,
        power,
    };

    // HeroMetadata struct creation
    let metadata = HeroMetadata {
        id: object::new(ctx),
        timestamp: tx_context::epoch_timestamp_ms(ctx),
    };

    // Make metadata immutable
    transfer::freeze_object(metadata);

    // Transfer hero to the transaction sender
    transfer::transfer(hero, tx_context::sender(ctx));
}

// ========= GETTER FUNCTIONS =========

public fun hero_power(hero: &Hero): u64 {
    hero.power
}

#[test_only]
public fun hero_name(hero: &Hero): String {
    hero.name
}

#[test_only]
public fun hero_image_url(hero: &Hero): String {
    hero.image_url
}

#[test_only]
public fun hero_id(hero: &Hero): ID {
    object::id(hero)
}

