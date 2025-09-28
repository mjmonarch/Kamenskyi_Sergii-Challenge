module challenge::arena;

use challenge::hero::Hero;
use sui::event;

// ========= STRUCTS =========

public struct Arena has key, store {
    id: UID,
    warrior: Hero,
    owner: address,
}

// ========= EVENTS =========

public struct ArenaCreated has copy, drop {
    arena_id: ID,
    timestamp: u64,
}

public struct ArenaCompleted has copy, drop {
    winner_hero_id: ID,
    loser_hero_id: ID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

public fun create_arena(hero: Hero, ctx: &mut TxContext) {

    // Arena struct creation
    let arena = Arena {
        id: object::new(ctx),
        warrior: hero,
        owner: tx_context::sender(ctx),
    };

    // Emit ArenaCreated event
    event::emit(
        ArenaCreated {
            arena_id: object::id(&arena),
            timestamp: tx_context::epoch_timestamp_ms(ctx),
        }
    );

    // Make arena publicly tradeable
    transfer::share_object(arena);
}

#[allow(lint(self_transfer))]
public fun battle(hero: Hero, arena: Arena, ctx: &mut TxContext) {

    // Arena destructuring
    let Arena { id: arena_id, warrior, owner: arena_owner } = arena;

    // Compare hero power to warrior power
    let hero_id = object::id(&hero);
    let warrior_id = object::id(&warrior);
    let hero_power: u64 = challenge::hero::hero_power(&hero);
    let warrior_power: u64 = challenge::hero::hero_power(&warrior);

    if (hero_power > warrior_power) {
        // Hero wins: both heroes go to ctx.sender()
        transfer::public_transfer(hero, tx_context::sender(ctx));
        transfer::public_transfer(warrior, tx_context::sender(ctx));

        // Emit ArenaCompleted event
        event::emit(
            ArenaCompleted {
                winner_hero_id: hero_id,
                loser_hero_id: warrior_id,
                timestamp: tx_context::epoch_timestamp_ms(ctx),
            }
        );
    } else {
        // Warrior wins: both heroes go to battle place owner
        transfer::public_transfer(hero, arena_owner);
        transfer::public_transfer(warrior, arena_owner);

        // Emit ArenaCompleted event
        event::emit(
            ArenaCompleted {
                winner_hero_id: warrior_id,
                loser_hero_id: hero_id,
                timestamp: tx_context::epoch_timestamp_ms(ctx),
            }
        );
    };

    // Delete the battle place ID
    object::delete(arena_id);
}

