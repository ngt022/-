--
-- PostgreSQL database dump
--

\restrict fjAfs3Xbg1xcKtD5Fx5MpBkyd6WketRzPPeYYWBiN3To1njBhVaaOqYWqhI3FoL

-- Dumped from database version 15.16 (Debian 15.16-0+deb12u1)
-- Dumped by pg_dump version 15.16 (Debian 15.16-0+deb12u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_logs; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.admin_logs (
    id integer NOT NULL,
    admin_wallet text NOT NULL,
    action text NOT NULL,
    target text,
    detail jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.admin_logs OWNER TO roon_user;

--
-- Name: admin_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.admin_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.admin_logs_id_seq OWNER TO roon_user;

--
-- Name: admin_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.admin_logs_id_seq OWNED BY public.admin_logs.id;


--
-- Name: announcements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcements (
    id integer NOT NULL,
    content text NOT NULL,
    type character varying(20) DEFAULT 'info'::character varying,
    active boolean DEFAULT true,
    sort_order integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.announcements OWNER TO postgres;

--
-- Name: announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.announcements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.announcements_id_seq OWNER TO postgres;

--
-- Name: announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.announcements_id_seq OWNED BY public.announcements.id;


--
-- Name: ascension_perks; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.ascension_perks (
    id integer NOT NULL,
    ascension_level integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    attack_bonus double precision DEFAULT 0,
    defense_bonus double precision DEFAULT 0,
    health_bonus double precision DEFAULT 0,
    speed_bonus double precision DEFAULT 0,
    cultivation_speed_bonus double precision DEFAULT 0,
    special_perk text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.ascension_perks OWNER TO roon_user;

--
-- Name: ascension_perks_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.ascension_perks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ascension_perks_id_seq OWNER TO roon_user;

--
-- Name: ascension_perks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.ascension_perks_id_seq OWNED BY public.ascension_perks.id;


--
-- Name: ascension_records; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.ascension_records (
    id integer NOT NULL,
    wallet character varying(255) NOT NULL,
    ascension_count integer DEFAULT 1 NOT NULL,
    previous_level integer DEFAULT 100 NOT NULL,
    bonuses jsonb DEFAULT '{}'::jsonb,
    ascended_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.ascension_records OWNER TO roon_user;

--
-- Name: ascension_records_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.ascension_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ascension_records_id_seq OWNER TO roon_user;

--
-- Name: ascension_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.ascension_records_id_seq OWNED BY public.ascension_records.id;


--
-- Name: auction_bids; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.auction_bids (
    id integer NOT NULL,
    listing_id integer NOT NULL,
    bidder_wallet character varying(255) NOT NULL,
    bidder_name character varying(255),
    bid_amount integer NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.auction_bids OWNER TO roon_user;

--
-- Name: auction_bids_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.auction_bids_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auction_bids_id_seq OWNER TO roon_user;

--
-- Name: auction_bids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.auction_bids_id_seq OWNED BY public.auction_bids.id;


--
-- Name: auction_history; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.auction_history (
    id integer NOT NULL,
    listing_id integer,
    seller_wallet character varying(255),
    buyer_wallet character varying(255),
    item_name character varying(255),
    item_type character varying(50),
    item_quality character varying(50),
    final_price integer,
    sold_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.auction_history OWNER TO roon_user;

--
-- Name: auction_history_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.auction_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auction_history_id_seq OWNER TO roon_user;

--
-- Name: auction_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.auction_history_id_seq OWNED BY public.auction_history.id;


--
-- Name: auction_listings; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.auction_listings (
    id integer NOT NULL,
    seller_wallet character varying(255) NOT NULL,
    seller_name character varying(255),
    item_data jsonb NOT NULL,
    item_name character varying(255) NOT NULL,
    item_type character varying(50) NOT NULL,
    item_quality character varying(50) NOT NULL,
    starting_price integer NOT NULL,
    buyout_price integer,
    current_bid integer DEFAULT 0,
    current_bidder character varying(255),
    bid_count integer DEFAULT 0,
    duration_hours integer NOT NULL,
    status character varying(20) DEFAULT 'active'::character varying,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.auction_listings OWNER TO roon_user;

--
-- Name: auction_listings_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.auction_listings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auction_listings_id_seq OWNER TO roon_user;

--
-- Name: auction_listings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.auction_listings_id_seq OWNED BY public.auction_listings.id;


--
-- Name: battle_trace_log; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.battle_trace_log (
    id bigint NOT NULL,
    battle_type character varying(20) NOT NULL,
    player_a_wallet character varying(42),
    player_b_wallet character varying(42),
    player_a_version bigint,
    player_b_version bigint,
    stats_a jsonb,
    stats_b jsonb,
    result jsonb,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.battle_trace_log OWNER TO roon_user;

--
-- Name: battle_trace_log_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.battle_trace_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.battle_trace_log_id_seq OWNER TO roon_user;

--
-- Name: battle_trace_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.battle_trace_log_id_seq OWNED BY public.battle_trace_log.id;


--
-- Name: boss_damage_log; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.boss_damage_log (
    id integer NOT NULL,
    boss_id integer,
    wallet character varying(100) NOT NULL,
    player_name character varying(100) DEFAULT '无名修士'::character varying,
    damage bigint DEFAULT 0,
    attacks_count integer DEFAULT 0,
    last_attack_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.boss_damage_log OWNER TO roon_user;

--
-- Name: boss_damage_log_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.boss_damage_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.boss_damage_log_id_seq OWNER TO roon_user;

--
-- Name: boss_damage_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.boss_damage_log_id_seq OWNED BY public.boss_damage_log.id;


--
-- Name: boss_rewards; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.boss_rewards (
    id integer NOT NULL,
    boss_id integer,
    wallet character varying(100) NOT NULL,
    rank integer DEFAULT 0,
    reward_stones integer DEFAULT 0,
    reward_items jsonb DEFAULT '[]'::jsonb,
    claimed boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.boss_rewards OWNER TO roon_user;

--
-- Name: boss_rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.boss_rewards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.boss_rewards_id_seq OWNER TO roon_user;

--
-- Name: boss_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.boss_rewards_id_seq OWNED BY public.boss_rewards.id;


--
-- Name: bug_reports; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.bug_reports (
    id integer NOT NULL,
    wallet text,
    player_name text,
    player_level integer,
    type text DEFAULT 'auto'::text,
    error_message text,
    error_stack text,
    description text,
    screenshot text,
    browser_info text,
    page_url text,
    extra_data jsonb,
    status text DEFAULT 'open'::text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.bug_reports OWNER TO roon_user;

--
-- Name: bug_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.bug_reports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bug_reports_id_seq OWNER TO roon_user;

--
-- Name: bug_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.bug_reports_id_seq OWNED BY public.bug_reports.id;


--
-- Name: daily_dungeon_entries; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.daily_dungeon_entries (
    id integer NOT NULL,
    dungeon_id integer NOT NULL,
    wallet character varying(42) NOT NULL,
    player_name character varying(50),
    result character varying(20) DEFAULT 'defeat'::character varying NOT NULL,
    rewards_earned jsonb DEFAULT '{}'::jsonb,
    entry_date date DEFAULT CURRENT_DATE NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.daily_dungeon_entries OWNER TO roon_user;

--
-- Name: daily_dungeon_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.daily_dungeon_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.daily_dungeon_entries_id_seq OWNER TO roon_user;

--
-- Name: daily_dungeon_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.daily_dungeon_entries_id_seq OWNED BY public.daily_dungeon_entries.id;


--
-- Name: daily_dungeons; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.daily_dungeons (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    difficulty character varying(20) DEFAULT 'easy'::character varying NOT NULL,
    min_level integer DEFAULT 1 NOT NULL,
    max_entries integer DEFAULT 3 NOT NULL,
    enemy_config jsonb DEFAULT '{}'::jsonb NOT NULL,
    rewards_config jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.daily_dungeons OWNER TO roon_user;

--
-- Name: daily_dungeons_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.daily_dungeons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.daily_dungeons_id_seq OWNER TO roon_user;

--
-- Name: daily_dungeons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.daily_dungeons_id_seq OWNED BY public.daily_dungeons.id;


--
-- Name: equip_slots; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.equip_slots (
    id integer NOT NULL,
    player_id integer NOT NULL,
    slot character varying(50) NOT NULL,
    item_id bigint,
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.equip_slots OWNER TO roon_user;

--
-- Name: equip_slots_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.equip_slots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.equip_slots_id_seq OWNER TO roon_user;

--
-- Name: equip_slots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.equip_slots_id_seq OWNED BY public.equip_slots.id;


--
-- Name: equipment; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.equipment (
    id integer NOT NULL,
    owner_id integer NOT NULL,
    name character varying(100) NOT NULL,
    type character varying(50),
    slot character varying(50),
    quality character varying(50) DEFAULT 'common'::character varying,
    level integer DEFAULT 1,
    required_realm integer DEFAULT 0,
    stats jsonb DEFAULT '{}'::jsonb,
    is_equipped boolean DEFAULT false,
    equipped_slot character varying(50),
    enhance_level integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.equipment OWNER TO roon_user;

--
-- Name: equipment_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.equipment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.equipment_id_seq OWNER TO roon_user;

--
-- Name: equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.equipment_id_seq OWNED BY public.equipment.id;


--
-- Name: event_claims; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event_claims (
    id integer NOT NULL,
    event_id integer,
    wallet character varying(42) NOT NULL,
    claimed_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.event_claims OWNER TO postgres;

--
-- Name: event_claims_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.event_claims_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.event_claims_id_seq OWNER TO postgres;

--
-- Name: event_claims_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.event_claims_id_seq OWNED BY public.event_claims.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.events (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    type character varying(30) NOT NULL,
    config jsonb DEFAULT '{}'::jsonb,
    starts_at timestamp without time zone NOT NULL,
    ends_at timestamp without time zone NOT NULL,
    active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    description text DEFAULT ''::text,
    rewards jsonb DEFAULT '[]'::jsonb
);


ALTER TABLE public.events OWNER TO postgres;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.events_id_seq OWNER TO postgres;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: friend_gifts; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.friend_gifts (
    id integer NOT NULL,
    from_wallet character varying(42) NOT NULL,
    to_wallet character varying(42) NOT NULL,
    gift_type character varying(30) DEFAULT 'spirit_stones'::character varying,
    gift_value integer DEFAULT 0,
    message text DEFAULT ''::text,
    claimed boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.friend_gifts OWNER TO roon_user;

--
-- Name: friend_gifts_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.friend_gifts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.friend_gifts_id_seq OWNER TO roon_user;

--
-- Name: friend_gifts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.friend_gifts_id_seq OWNED BY public.friend_gifts.id;


--
-- Name: friendships; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.friendships (
    id integer NOT NULL,
    from_wallet character varying(42) NOT NULL,
    to_wallet character varying(42) NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.friendships OWNER TO roon_user;

--
-- Name: friendships_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.friendships_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.friendships_id_seq OWNER TO roon_user;

--
-- Name: friendships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.friendships_id_seq OWNED BY public.friendships.id;


--
-- Name: idempotency_cache; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.idempotency_cache (
    key character varying(200) NOT NULL,
    status_code integer NOT NULL,
    response jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.idempotency_cache OWNER TO roon_user;

--
-- Name: inventory_items; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.inventory_items (
    id bigint NOT NULL,
    player_id integer NOT NULL,
    original_id text,
    name character varying(100) NOT NULL,
    type character varying(50) NOT NULL,
    quality character varying(50) DEFAULT 'common'::character varying,
    stats jsonb DEFAULT '{}'::jsonb NOT NULL,
    attributes jsonb DEFAULT '{}'::jsonb,
    enhance_level integer DEFAULT 0,
    required_realm integer DEFAULT 0,
    source character varying(50) DEFAULT 'unknown'::character varying,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.inventory_items OWNER TO roon_user;

--
-- Name: inventory_items_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.inventory_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventory_items_id_seq OWNER TO roon_user;

--
-- Name: inventory_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.inventory_items_id_seq OWNED BY public.inventory_items.id;


--
-- Name: leaderboard_cache; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.leaderboard_cache (
    id integer NOT NULL,
    type character varying(20) NOT NULL,
    data jsonb DEFAULT '[]'::jsonb,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.leaderboard_cache OWNER TO postgres;

--
-- Name: leaderboard_cache_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.leaderboard_cache_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.leaderboard_cache_id_seq OWNER TO postgres;

--
-- Name: leaderboard_cache_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.leaderboard_cache_id_seq OWNED BY public.leaderboard_cache.id;


--
-- Name: login_logs; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.login_logs (
    id integer NOT NULL,
    wallet character varying(42) NOT NULL,
    ip character varying(45),
    user_agent character varying(200),
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.login_logs OWNER TO roon_user;

--
-- Name: login_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.login_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.login_logs_id_seq OWNER TO roon_user;

--
-- Name: login_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.login_logs_id_seq OWNED BY public.login_logs.id;


--
-- Name: monthly_cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.monthly_cards (
    id integer NOT NULL,
    wallet character varying(42) NOT NULL,
    purchased_at timestamp without time zone DEFAULT now(),
    expires_at timestamp without time zone NOT NULL,
    last_claim_date date,
    days_claimed integer DEFAULT 0
);


ALTER TABLE public.monthly_cards OWNER TO postgres;

--
-- Name: monthly_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.monthly_cards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.monthly_cards_id_seq OWNER TO postgres;

--
-- Name: monthly_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.monthly_cards_id_seq OWNED BY public.monthly_cards.id;


--
-- Name: mounts; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.mounts (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    quality character varying(20) DEFAULT 'common'::character varying,
    emoji character varying(10),
    attack_bonus double precision DEFAULT 0,
    defense_bonus double precision DEFAULT 0,
    health_bonus double precision DEFAULT 0,
    speed_bonus double precision DEFAULT 0,
    special_effect text,
    obtain_method text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.mounts OWNER TO roon_user;

--
-- Name: mounts_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.mounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mounts_id_seq OWNER TO roon_user;

--
-- Name: mounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.mounts_id_seq OWNED BY public.mounts.id;


--
-- Name: pets; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.pets (
    id integer NOT NULL,
    owner_id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    rarity character varying(50) DEFAULT 'mortal'::character varying,
    level integer DEFAULT 1,
    star integer DEFAULT 0,
    combat_attributes jsonb DEFAULT '{}'::jsonb,
    is_active boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.pets OWNER TO roon_user;

--
-- Name: pets_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.pets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pets_id_seq OWNER TO roon_user;

--
-- Name: pets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.pets_id_seq OWNED BY public.pets.id;


--
-- Name: pk_rankings; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.pk_rankings (
    id integer NOT NULL,
    wallet character varying(42) NOT NULL,
    rank_score integer DEFAULT 1000,
    rank_tier character varying(20) DEFAULT 'silver'::character varying,
    season integer DEFAULT 1,
    wins integer DEFAULT 0,
    losses integer DEFAULT 0,
    draws integer DEFAULT 0,
    win_streak integer DEFAULT 0,
    max_win_streak integer DEFAULT 0,
    last_pk_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.pk_rankings OWNER TO roon_user;

--
-- Name: pk_rankings_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.pk_rankings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pk_rankings_id_seq OWNER TO roon_user;

--
-- Name: pk_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.pk_rankings_id_seq OWNED BY public.pk_rankings.id;


--
-- Name: pk_records; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pk_records (
    id integer NOT NULL,
    wallet_a character varying(42) NOT NULL,
    wallet_b character varying(42) NOT NULL,
    name_a character varying(50),
    name_b character varying(50),
    winner character(1),
    winner_wallet character varying(42),
    rounds_data jsonb DEFAULT '[]'::jsonb,
    reward integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    bet_amount integer DEFAULT 0,
    score_change_a integer DEFAULT 0,
    score_change_b integer DEFAULT 0
);


ALTER TABLE public.pk_records OWNER TO postgres;

--
-- Name: pk_records_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pk_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pk_records_id_seq OWNER TO postgres;

--
-- Name: pk_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pk_records_id_seq OWNED BY public.pk_records.id;


--
-- Name: player_mail; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.player_mail (
    id integer NOT NULL,
    to_wallet character varying(42) NOT NULL,
    from_type character varying(20) DEFAULT 'system'::character varying NOT NULL,
    from_name character varying(50) DEFAULT '系统'::character varying,
    title character varying(100) NOT NULL,
    content text NOT NULL,
    rewards jsonb DEFAULT '{}'::jsonb,
    is_read boolean DEFAULT false,
    is_claimed boolean DEFAULT false,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    from_wallet character varying(42) DEFAULT NULL::character varying
);


ALTER TABLE public.player_mail OWNER TO roon_user;

--
-- Name: player_mail_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.player_mail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.player_mail_id_seq OWNER TO roon_user;

--
-- Name: player_mail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.player_mail_id_seq OWNED BY public.player_mail.id;


--
-- Name: player_mounts; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.player_mounts (
    id integer NOT NULL,
    wallet character varying(100) NOT NULL,
    mount_id integer,
    level integer DEFAULT 1,
    exp integer DEFAULT 0,
    is_active boolean DEFAULT false,
    obtained_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.player_mounts OWNER TO roon_user;

--
-- Name: player_mounts_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.player_mounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.player_mounts_id_seq OWNER TO roon_user;

--
-- Name: player_mounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.player_mounts_id_seq OWNED BY public.player_mounts.id;


--
-- Name: player_stats_snapshot; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.player_stats_snapshot (
    player_id integer NOT NULL,
    state_version bigint DEFAULT 0 NOT NULL,
    final_stats jsonb DEFAULT '{}'::jsonb NOT NULL,
    computed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.player_stats_snapshot OWNER TO roon_user;

--
-- Name: player_titles; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.player_titles (
    id integer NOT NULL,
    wallet character varying(100) NOT NULL,
    title_id integer,
    is_active boolean DEFAULT false,
    obtained_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.player_titles OWNER TO roon_user;

--
-- Name: player_titles_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.player_titles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.player_titles_id_seq OWNER TO roon_user;

--
-- Name: player_titles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.player_titles_id_seq OWNED BY public.player_titles.id;


--
-- Name: players; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.players (
    id integer NOT NULL,
    wallet character varying(42) NOT NULL,
    name character varying(50) DEFAULT '无名修士'::character varying,
    game_data jsonb DEFAULT '{}'::jsonb,
    vip_level integer DEFAULT 0,
    total_recharge numeric(20,8) DEFAULT 0,
    spirit_stones bigint DEFAULT 0,
    level integer DEFAULT 1,
    realm character varying(50) DEFAULT '燃火期一层'::character varying,
    combat_power bigint DEFAULT 0,
    first_recharge boolean DEFAULT false,
    daily_sign_date date,
    daily_sign_streak integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    banned boolean DEFAULT false,
    state_version integer DEFAULT 0
);


ALTER TABLE public.players OWNER TO postgres;

--
-- Name: players_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.players_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.players_id_seq OWNER TO postgres;

--
-- Name: players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.players_id_seq OWNED BY public.players.id;


--
-- Name: private_messages; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.private_messages (
    id integer NOT NULL,
    from_wallet character varying(42) NOT NULL,
    to_wallet character varying(42) NOT NULL,
    content text NOT NULL,
    is_read boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.private_messages OWNER TO roon_user;

--
-- Name: private_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.private_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.private_messages_id_seq OWNER TO roon_user;

--
-- Name: private_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.private_messages_id_seq OWNED BY public.private_messages.id;


--
-- Name: recharge_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recharge_log (
    id integer NOT NULL,
    wallet character varying(42) NOT NULL,
    tx_hash character varying(66) NOT NULL,
    amount numeric(20,8) NOT NULL,
    spirit_stones bigint NOT NULL,
    bonus_stones bigint DEFAULT 0,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.recharge_log OWNER TO postgres;

--
-- Name: recharge_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.recharge_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.recharge_log_id_seq OWNER TO postgres;

--
-- Name: recharge_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.recharge_log_id_seq OWNED BY public.recharge_log.id;


--
-- Name: sect_members; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.sect_members (
    id integer NOT NULL,
    sect_id integer,
    wallet character varying(100) NOT NULL,
    role character varying(20) DEFAULT 'member'::character varying,
    contribution bigint DEFAULT 0,
    joined_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.sect_members OWNER TO roon_user;

--
-- Name: sect_members_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.sect_members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sect_members_id_seq OWNER TO roon_user;

--
-- Name: sect_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.sect_members_id_seq OWNED BY public.sect_members.id;


--
-- Name: sect_tasks; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.sect_tasks (
    id integer NOT NULL,
    sect_id integer,
    type character varying(10) DEFAULT 'daily'::character varying,
    title character varying(100) NOT NULL,
    description text DEFAULT ''::text,
    reward_contribution integer DEFAULT 10,
    reward_stones integer DEFAULT 100,
    completed_by jsonb DEFAULT '[]'::jsonb,
    reset_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.sect_tasks OWNER TO roon_user;

--
-- Name: sect_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.sect_tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sect_tasks_id_seq OWNER TO roon_user;

--
-- Name: sect_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.sect_tasks_id_seq OWNED BY public.sect_tasks.id;


--
-- Name: sect_war_participants; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.sect_war_participants (
    id integer NOT NULL,
    war_id integer NOT NULL,
    sect_id integer NOT NULL,
    wallet character varying(255) NOT NULL,
    player_name character varying(100),
    combat_power bigint DEFAULT 0,
    result character varying(10) DEFAULT 'pending'::character varying,
    damage_dealt bigint DEFAULT 0,
    round_number integer
);


ALTER TABLE public.sect_war_participants OWNER TO roon_user;

--
-- Name: sect_war_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.sect_war_participants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sect_war_participants_id_seq OWNER TO roon_user;

--
-- Name: sect_war_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.sect_war_participants_id_seq OWNED BY public.sect_war_participants.id;


--
-- Name: sect_war_rankings; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.sect_war_rankings (
    id integer NOT NULL,
    sect_id integer NOT NULL,
    season integer DEFAULT 1,
    wins integer DEFAULT 0,
    losses integer DEFAULT 0,
    points integer DEFAULT 0,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.sect_war_rankings OWNER TO roon_user;

--
-- Name: sect_war_rankings_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.sect_war_rankings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sect_war_rankings_id_seq OWNER TO roon_user;

--
-- Name: sect_war_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.sect_war_rankings_id_seq OWNED BY public.sect_war_rankings.id;


--
-- Name: sect_war_rewards; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.sect_war_rewards (
    id integer NOT NULL,
    war_id integer NOT NULL,
    sect_id integer NOT NULL,
    wallet character varying(255) NOT NULL,
    reward_stones integer DEFAULT 0,
    reward_contribution integer DEFAULT 0,
    claimed boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.sect_war_rewards OWNER TO roon_user;

--
-- Name: sect_war_rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.sect_war_rewards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sect_war_rewards_id_seq OWNER TO roon_user;

--
-- Name: sect_war_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.sect_war_rewards_id_seq OWNED BY public.sect_war_rewards.id;


--
-- Name: sect_wars; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.sect_wars (
    id integer NOT NULL,
    challenger_sect_id integer NOT NULL,
    defender_sect_id integer NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    challenger_score integer DEFAULT 0,
    defender_score integer DEFAULT 0,
    winner_sect_id integer,
    rounds_data jsonb,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.sect_wars OWNER TO roon_user;

--
-- Name: sect_wars_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.sect_wars_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sect_wars_id_seq OWNER TO roon_user;

--
-- Name: sect_wars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.sect_wars_id_seq OWNED BY public.sect_wars.id;


--
-- Name: sects; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.sects (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    description text DEFAULT ''::text,
    leader_wallet character varying(100) NOT NULL,
    level integer DEFAULT 1,
    exp bigint DEFAULT 0,
    max_members integer DEFAULT 20,
    announcement text DEFAULT '欢迎加入本宗门！'::text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.sects OWNER TO roon_user;

--
-- Name: sects_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.sects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sects_id_seq OWNER TO roon_user;

--
-- Name: sects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.sects_id_seq OWNED BY public.sects.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.settings (
    key text NOT NULL,
    value jsonb NOT NULL,
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.settings OWNER TO roon_user;

--
-- Name: titles; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.titles (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    quality character varying(20) DEFAULT 'common'::character varying,
    color character varying(20),
    condition_type character varying(50),
    condition_value integer,
    attack_bonus double precision DEFAULT 0,
    defense_bonus double precision DEFAULT 0,
    health_bonus double precision DEFAULT 0,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.titles OWNER TO roon_user;

--
-- Name: titles_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.titles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.titles_id_seq OWNER TO roon_user;

--
-- Name: titles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.titles_id_seq OWNED BY public.titles.id;


--
-- Name: world_bosses; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.world_bosses (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    level integer DEFAULT 1,
    max_hp bigint NOT NULL,
    current_hp bigint NOT NULL,
    attack integer DEFAULT 100,
    defense integer DEFAULT 50,
    description text DEFAULT ''::text,
    rewards_config jsonb DEFAULT '{}'::jsonb,
    status character varying(20) DEFAULT 'waiting'::character varying,
    spawn_time timestamp with time zone,
    death_time timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.world_bosses OWNER TO roon_user;

--
-- Name: world_bosses_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.world_bosses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.world_bosses_id_seq OWNER TO roon_user;

--
-- Name: world_bosses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.world_bosses_id_seq OWNED BY public.world_bosses.id;


--
-- Name: admin_logs id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.admin_logs ALTER COLUMN id SET DEFAULT nextval('public.admin_logs_id_seq'::regclass);


--
-- Name: announcements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements ALTER COLUMN id SET DEFAULT nextval('public.announcements_id_seq'::regclass);


--
-- Name: ascension_perks id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.ascension_perks ALTER COLUMN id SET DEFAULT nextval('public.ascension_perks_id_seq'::regclass);


--
-- Name: ascension_records id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.ascension_records ALTER COLUMN id SET DEFAULT nextval('public.ascension_records_id_seq'::regclass);


--
-- Name: auction_bids id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.auction_bids ALTER COLUMN id SET DEFAULT nextval('public.auction_bids_id_seq'::regclass);


--
-- Name: auction_history id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.auction_history ALTER COLUMN id SET DEFAULT nextval('public.auction_history_id_seq'::regclass);


--
-- Name: auction_listings id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.auction_listings ALTER COLUMN id SET DEFAULT nextval('public.auction_listings_id_seq'::regclass);


--
-- Name: battle_trace_log id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.battle_trace_log ALTER COLUMN id SET DEFAULT nextval('public.battle_trace_log_id_seq'::regclass);


--
-- Name: boss_damage_log id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.boss_damage_log ALTER COLUMN id SET DEFAULT nextval('public.boss_damage_log_id_seq'::regclass);


--
-- Name: boss_rewards id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.boss_rewards ALTER COLUMN id SET DEFAULT nextval('public.boss_rewards_id_seq'::regclass);


--
-- Name: bug_reports id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.bug_reports ALTER COLUMN id SET DEFAULT nextval('public.bug_reports_id_seq'::regclass);


--
-- Name: daily_dungeon_entries id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.daily_dungeon_entries ALTER COLUMN id SET DEFAULT nextval('public.daily_dungeon_entries_id_seq'::regclass);


--
-- Name: daily_dungeons id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.daily_dungeons ALTER COLUMN id SET DEFAULT nextval('public.daily_dungeons_id_seq'::regclass);


--
-- Name: equip_slots id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.equip_slots ALTER COLUMN id SET DEFAULT nextval('public.equip_slots_id_seq'::regclass);


--
-- Name: equipment id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.equipment ALTER COLUMN id SET DEFAULT nextval('public.equipment_id_seq'::regclass);


--
-- Name: event_claims id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_claims ALTER COLUMN id SET DEFAULT nextval('public.event_claims_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: friend_gifts id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.friend_gifts ALTER COLUMN id SET DEFAULT nextval('public.friend_gifts_id_seq'::regclass);


--
-- Name: friendships id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.friendships ALTER COLUMN id SET DEFAULT nextval('public.friendships_id_seq'::regclass);


--
-- Name: inventory_items id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.inventory_items ALTER COLUMN id SET DEFAULT nextval('public.inventory_items_id_seq'::regclass);


--
-- Name: leaderboard_cache id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leaderboard_cache ALTER COLUMN id SET DEFAULT nextval('public.leaderboard_cache_id_seq'::regclass);


--
-- Name: login_logs id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.login_logs ALTER COLUMN id SET DEFAULT nextval('public.login_logs_id_seq'::regclass);


--
-- Name: monthly_cards id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monthly_cards ALTER COLUMN id SET DEFAULT nextval('public.monthly_cards_id_seq'::regclass);


--
-- Name: mounts id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.mounts ALTER COLUMN id SET DEFAULT nextval('public.mounts_id_seq'::regclass);


--
-- Name: pets id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.pets ALTER COLUMN id SET DEFAULT nextval('public.pets_id_seq'::regclass);


--
-- Name: pk_rankings id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.pk_rankings ALTER COLUMN id SET DEFAULT nextval('public.pk_rankings_id_seq'::regclass);


--
-- Name: pk_records id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pk_records ALTER COLUMN id SET DEFAULT nextval('public.pk_records_id_seq'::regclass);


--
-- Name: player_mail id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.player_mail ALTER COLUMN id SET DEFAULT nextval('public.player_mail_id_seq'::regclass);


--
-- Name: player_mounts id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.player_mounts ALTER COLUMN id SET DEFAULT nextval('public.player_mounts_id_seq'::regclass);


--
-- Name: player_titles id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.player_titles ALTER COLUMN id SET DEFAULT nextval('public.player_titles_id_seq'::regclass);


--
-- Name: players id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players ALTER COLUMN id SET DEFAULT nextval('public.players_id_seq'::regclass);


--
-- Name: private_messages id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.private_messages ALTER COLUMN id SET DEFAULT nextval('public.private_messages_id_seq'::regclass);


--
-- Name: recharge_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recharge_log ALTER COLUMN id SET DEFAULT nextval('public.recharge_log_id_seq'::regclass);


--
-- Name: sect_members id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_members ALTER COLUMN id SET DEFAULT nextval('public.sect_members_id_seq'::regclass);


--
-- Name: sect_tasks id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_tasks ALTER COLUMN id SET DEFAULT nextval('public.sect_tasks_id_seq'::regclass);


--
-- Name: sect_war_participants id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_war_participants ALTER COLUMN id SET DEFAULT nextval('public.sect_war_participants_id_seq'::regclass);


--
-- Name: sect_war_rankings id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_war_rankings ALTER COLUMN id SET DEFAULT nextval('public.sect_war_rankings_id_seq'::regclass);


--
-- Name: sect_war_rewards id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_war_rewards ALTER COLUMN id SET DEFAULT nextval('public.sect_war_rewards_id_seq'::regclass);


--
-- Name: sect_wars id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_wars ALTER COLUMN id SET DEFAULT nextval('public.sect_wars_id_seq'::regclass);


--
-- Name: sects id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sects ALTER COLUMN id SET DEFAULT nextval('public.sects_id_seq'::regclass);


--
-- Name: titles id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.titles ALTER COLUMN id SET DEFAULT nextval('public.titles_id_seq'::regclass);


--
-- Name: world_bosses id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.world_bosses ALTER COLUMN id SET DEFAULT nextval('public.world_bosses_id_seq'::regclass);


--
-- Data for Name: admin_logs; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.admin_logs (id, admin_wallet, action, target, detail, created_at) FROM stdin;
\.


--
-- Data for Name: announcements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.announcements (id, content, type, active, sort_order, created_at) FROM stdin;
7	🔥 欢迎来到「火之文明」内测！连接钱包即可开始修炼之旅，遇到问题请点右下角🐛反馈	info	t	1	2026-02-23 07:31:09.445624
8	📖 新手攻略：冥想(消耗焰灵→获得焰力)→突破境界→探索获取焰草焰晶→抽卡获得装备焰兽→提升战力	info	t	2	2026-02-23 07:31:09.445624
9	🧘 核心玩法：焰灵自动恢复，点「一键冥想」消耗全部焰灵换焰力，焰力满了就能突破升级！	info	t	3	2026-02-23 07:31:09.445624
10	🗺️ 探索地图：薪火村(1级)→赤霄峰(10级)→涅槃谷(19级)→焰渊(28级)→焰天圣域(37级)，可获焰草、焰晶、丹方残页	info	t	4	2026-02-23 07:31:09.445624
11	🎰 抽卡系统：单抽300焰晶，装备6品质(凡→良→优→极→仙→神)，焰兽5品质，有保底机制	info	t	5	2026-02-23 07:31:09.445624
12	💎 赚焰晶途径：冥想离线收益、探索、签到(每日500-5000)、每日副本、PK胜利、回收多余物品	info	t	6	2026-02-23 07:31:09.445624
13	💳 薪火令(月卡)：10 ROON/30天，每日5000焰晶+冥想加速20%+免费抽卡1次，超值推荐！	promo	t	7	2026-02-23 07:31:09.445624
14	⚔️ 提升战力：穿装备→淬火强化→出战焰兽→服用焰丹buff→挑战PK和世界Boss！	info	t	8	2026-02-23 07:31:09.445624
15	🧪 内测公告：火之文明开启为期3天的内测（2/23-2/26），所有参与内测的玩家赠送100,000焰晶！内测期间充值系统暂时关闭，感谢各位焰修者的支持！	event	t	0	2026-02-23 07:31:09.445624
\.


--
-- Data for Name: ascension_perks; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.ascension_perks (id, ascension_level, name, description, attack_bonus, defense_bonus, health_bonus, speed_bonus, cultivation_speed_bonus, special_perk, created_at) FROM stdin;
\.


--
-- Data for Name: ascension_records; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.ascension_records (id, wallet, ascension_count, previous_level, bonuses, ascended_at) FROM stdin;
\.


--
-- Data for Name: auction_bids; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.auction_bids (id, listing_id, bidder_wallet, bidder_name, bid_amount, created_at) FROM stdin;
\.


--
-- Data for Name: auction_history; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.auction_history (id, listing_id, seller_wallet, buyer_wallet, item_name, item_type, item_quality, final_price, sold_at) FROM stdin;
4	10	0x82e402b05f3e936b63a874788c73e1552657c4f7	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	玄阳衣服·仙	body	epic	5000	2026-02-23 12:18:57.322362
\.


--
-- Data for Name: auction_listings; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.auction_listings (id, seller_wallet, seller_name, item_data, item_name, item_type, item_quality, starting_price, buyout_price, current_bid, current_bidder, bid_count, duration_hours, status, expires_at, created_at) FROM stdin;
9	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名焰修	{"id": 1771866952781.0637, "name": "玄阳衣服·仙", "slot": "body", "type": "body", "level": 3, "stats": {"health": 417, "defense": 60, "finalDamageReduce": 0.45}, "quality": "epic", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 3}	玄阳衣服·仙	body	epic	100	5000	0	\N	0	24	cancelled	2026-02-24 17:16:24.51	2026-02-23 12:16:24.511396
10	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名焰修	{"id": 1771866952781.0637, "name": "玄阳衣服·仙", "slot": "body", "type": "body", "level": 3, "stats": {"health": 417, "defense": 60, "finalDamageReduce": 0.45}, "quality": "epic", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 3}	玄阳衣服·仙	body	epic	4000	5000	5000	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	0	24	sold	2026-02-24 17:18:25.076	2026-02-23 12:18:25.076702
11	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	疯狂的小三	{"id": 1771866952781.0637, "name": "玄阳衣服·仙", "slot": "body", "type": "body", "level": 3, "stats": {"health": 417, "defense": 60, "finalDamageReduce": 0.45}, "quality": "epic", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 3}	玄阳衣服·仙	body	epic	100	1000	0	\N	0	24	cancelled	2026-02-24 17:19:24.17	2026-02-23 12:19:24.170546
\.


--
-- Data for Name: battle_trace_log; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.battle_trace_log (id, battle_type, player_a_wallet, player_b_wallet, player_a_version, player_b_version, stats_a, stats_b, result, created_at) FROM stdin;
\.


--
-- Data for Name: boss_damage_log; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.boss_damage_log (id, boss_id, wallet, player_name, damage, attacks_count, last_attack_at) FROM stdin;
\.


--
-- Data for Name: boss_rewards; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.boss_rewards (id, boss_id, wallet, rank, reward_stones, reward_items, claimed, created_at) FROM stdin;
\.


--
-- Data for Name: bug_reports; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.bug_reports (id, wallet, player_name, player_level, type, error_message, error_stack, description, screenshot, browser_info, page_url, extra_data, status, created_at) FROM stdin;
1	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	疯狂的小三	7	manual			冥想失败：Load failed		Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	https://flamecraft.mkoa.top/#/cultivation	{"playerName": "疯狂的小三", "playerLevel": 7}	open	2026-02-23 08:43:22.538745-05
2	\N	\N	\N	manual			test				{}	open	2026-02-23 08:43:26.15416-05
3	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	疯狂的小三	7	auto	Importing a module script failed.				Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	https://flamecraft.mkoa.top/#/	{"playerName": "疯狂的小三", "playerLevel": 7}	open	2026-02-23 08:44:05.408166-05
4	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名焰修	1	auto	Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Cultivation-BcyosznW.js	TypeError: Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Cultivation-BcyosznW.js			Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	https://flamecraft.mkoa.top/#/	{"playerName": "无名焰修", "playerLevel": 1}	open	2026-02-23 11:15:07.283473-05
5	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名焰修	1	auto	Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Profile-BdGcAjwO.js	TypeError: Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Profile-BdGcAjwO.js			Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	https://flamecraft.mkoa.top/#/	{"playerName": "无名焰修", "playerLevel": 1}	open	2026-02-23 11:15:19.786157-05
6	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名焰修	1	auto	Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Sect-CFmKcxiE.js	TypeError: Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Sect-CFmKcxiE.js			Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	https://flamecraft.mkoa.top/#/	{"playerName": "无名焰修", "playerLevel": 1}	open	2026-02-23 11:15:24.648764-05
7	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名焰修	1	auto	Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Shop-C1kJZKkl.js	TypeError: Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Shop-C1kJZKkl.js			Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	https://flamecraft.mkoa.top/#/	{"playerName": "无名焰修", "playerLevel": 1}	open	2026-02-23 11:15:29.446613-05
8	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名焰修	1	auto	Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Vip-CaV5UUGV.js	TypeError: Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Vip-CaV5UUGV.js			Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	https://flamecraft.mkoa.top/#/	{"playerName": "无名焰修", "playerLevel": 1}	open	2026-02-23 11:15:49.935985-05
9	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名焰修	1	auto	Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Gacha-CxMPo8Od.js	TypeError: Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Gacha-CxMPo8Od.js			Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	https://flamecraft.mkoa.top/#/	{"playerName": "无名焰修", "playerLevel": 1}	open	2026-02-23 11:15:52.094841-05
10	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名焰修	1	auto	Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Events-DQvEK2kw.js	TypeError: Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Events-DQvEK2kw.js			Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	https://flamecraft.mkoa.top/#/	{"playerName": "无名焰修", "playerLevel": 1}	open	2026-02-23 11:15:54.224395-05
11	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名焰修	1	auto	Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Alchemy-BQXKNRv3.js	TypeError: Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Alchemy-BQXKNRv3.js			Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	https://flamecraft.mkoa.top/#/	{"playerName": "无名焰修", "playerLevel": 1}	open	2026-02-23 11:16:01.029871-05
12	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名焰修	1	auto	Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Exploration-CJNlNidU.js	TypeError: Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Exploration-CJNlNidU.js			Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	https://flamecraft.mkoa.top/#/	{"playerName": "无名焰修", "playerLevel": 1}	open	2026-02-23 11:16:03.139895-05
13	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	疯狂的小三	13	auto	Importing a module script failed.				Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	https://flamecraft.mkoa.top/#/	{"playerName": "疯狂的小三", "playerLevel": 13}	open	2026-02-23 11:20:22.299143-05
14	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名焰修	3	auto	Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Home-BZ85ES6k.js	TypeError: Failed to fetch dynamically imported module: https://flamecraft.mkoa.top/assets/js/Home-BZ85ES6k.js			Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	https://flamecraft.mkoa.top/#/pk	{"playerName": "无名焰修", "playerLevel": 3}	open	2026-02-23 12:00:15.745542-05
15	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	疯狂的小三	16	auto	Unable to preload CSS for https://flamecraft.mkoa.top/assets/css/Rank-a-PBqdFb.css	@https://flamecraft.mkoa.top/assets/js/index-BuTNc1hv.js:2:2320			Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	https://flamecraft.mkoa.top/#/	{"playerName": "疯狂的小三", "playerLevel": 16}	open	2026-02-23 13:37:04.344528-05
16	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	疯狂的小三	16	auto	Unable to preload CSS for https://flamecraft.mkoa.top/assets/css/GameGuide-D-sLEQoa.css	@https://flamecraft.mkoa.top/assets/js/index-BuTNc1hv.js:2:2320			Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	https://flamecraft.mkoa.top/#/	{"playerName": "疯狂的小三", "playerLevel": 16}	open	2026-02-23 13:37:09.233565-05
\.


--
-- Data for Name: daily_dungeon_entries; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.daily_dungeon_entries (id, dungeon_id, wallet, player_name, result, rewards_earned, entry_date, created_at) FROM stdin;
\.


--
-- Data for Name: daily_dungeons; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.daily_dungeons (id, name, description, difficulty, min_level, max_entries, enemy_config, rewards_config, created_at) FROM stdin;
1	焰草秘境	蕴含丰富焰草的秘境，击败守护兽可获得珍稀焰草	easy	1	3	{"hp": 5000, "name": "灵草守护兽", "level": 20, "attack": 200, "defense": 100}	{"items": ["灵草"], "cultivation": 500, "spiritStones": 2000}	2026-02-18 07:19:33.079678
2	丹火洞天	远古炼丹师留下的洞天，内有强大的火灵	normal	10	3	{"hp": 20000, "name": "火灵", "level": 50, "attack": 800, "defense": 400}	{"items": ["丹方碎片"], "cultivation": 2000, "spiritStones": 5000}	2026-02-18 07:19:33.079678
3	万兽山	凶兽横行的险地，击败兽王可获得焰兽精华	hard	30	2	{"hp": 80000, "name": "万兽之王", "level": 80, "attack": 3000, "defense": 1500}	{"petEssence": 10, "cultivation": 5000, "spiritStones": 10000}	2026-02-18 07:19:33.079678
4	焰魔战场	上古焰魔大战的遗迹，极其危险但奖励丰厚	hell	50	1	{"hp": 300000, "name": "残魂魔将", "level": 120, "attack": 10000, "defense": 5000}	{"cultivation": 15000, "spiritStones": 30000, "refinementStones": 20}	2026-02-18 07:19:33.079678
\.


--
-- Data for Name: equip_slots; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.equip_slots (id, player_id, slot, item_id, updated_at) FROM stdin;
4	14	weapon	2	2026-02-23 12:08:47.947664-05
5	14	head	3	2026-02-23 12:08:48.178761-05
6	14	body	4	2026-02-23 12:08:48.390841-05
7	14	legs	5	2026-02-23 12:08:48.600175-05
8	14	feet	6	2026-02-23 12:08:48.808458-05
9	14	shoulder	7	2026-02-23 12:08:49.0384-05
10	14	hands	8	2026-02-23 12:08:49.249878-05
11	14	wrist	9	2026-02-23 12:08:49.534625-05
12	14	necklace	10	2026-02-23 12:08:49.759665-05
13	14	ring1	11	2026-02-23 12:08:49.988918-05
14	14	ring2	12	2026-02-23 12:08:50.195362-05
15	16	weapon	1	2026-02-23 12:10:42.082845-05
18	16	head	14	2026-02-23 12:21:03.700472-05
17	16	body	15	2026-02-23 12:21:04.079152-05
20	16	legs	16	2026-02-23 12:21:04.496769-05
21	16	feet	17	2026-02-23 12:21:04.999768-05
22	16	shoulder	18	2026-02-23 12:21:05.327867-05
23	16	hands	19	2026-02-23 12:21:05.710261-05
24	16	wrist	20	2026-02-23 12:21:06.068207-05
25	16	necklace	21	2026-02-23 12:21:06.390685-05
26	16	ring1	22	2026-02-23 12:21:06.800773-05
27	16	ring2	23	2026-02-23 12:21:07.789345-05
28	16	belt	24	2026-02-23 12:21:08.189331-05
29	16	artifact	25	2026-02-23 12:21:08.607434-05
\.


--
-- Data for Name: equipment; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.equipment (id, owner_id, name, type, slot, quality, level, required_realm, stats, is_equipped, equipped_slot, enhance_level, created_at) FROM stdin;
\.


--
-- Data for Name: event_claims; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.event_claims (id, event_id, wallet, claimed_at) FROM stdin;
3	6	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	2026-02-23 11:21:10.550958-05
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.events (id, name, type, config, starts_at, ends_at, active, created_at, description, rewards) FROM stdin;
6	开服庆典	login_bonus	{"dailyStones": 5000}	2026-02-21 04:17:15.214367	2026-03-23 04:17:15.214367	t	2026-02-21 04:17:15.214367	开服期间每日登录领取5000焰晶！	[{"type": "spiritStones", "amount": 5000}]
\.


--
-- Data for Name: friend_gifts; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.friend_gifts (id, from_wallet, to_wallet, gift_type, gift_value, message, claimed, created_at) FROM stdin;
\.


--
-- Data for Name: friendships; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.friendships (id, from_wallet, to_wallet, status, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: idempotency_cache; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.idempotency_cache (key, status_code, response, created_at) FROM stdin;
\.


--
-- Data for Name: inventory_items; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.inventory_items (id, player_id, original_id, name, type, quality, stats, attributes, enhance_level, required_realm, source, created_at) FROM stdin;
1	16	1771863710323.9473	幽冥焰杖·圣	weapon	legendary	{"attack": 106, "critRate": 0.19, "critDamageBoost": 0.32}	{}	0	0	game	2026-02-23 11:21:59.55781-05
2	14	1771866494846.1091	赤炎焰杖·圣	weapon	legendary	{"attack": 95, "critRate": 0.1, "critDamageBoost": 0.15}	{}	0	0	game	2026-02-23 12:08:47.947664-05
3	14	1771866506468.2437	玄冥头部·仙	head	epic	{"health": 473, "defense": 44, "stunResist": 0.41}	{}	0	0	game	2026-02-23 12:08:48.178761-05
4	14	1771866504562.0095	太素衣服·仙	body	epic	{"health": 543, "defense": 59, "finalDamageReduce": 0.29}	{}	0	0	game	2026-02-23 12:08:48.390841-05
5	14	1771866508146.2104	紫电裤子·仙	legs	epic	{"speed": 34, "defense": 47, "dodgeRate": 0.09}	{}	0	0	game	2026-02-23 12:08:48.600175-05
6	14	1771866509747.372	幽影鞋子·仙	feet	epic	{"speed": 37, "defense": 23, "dodgeRate": 0.12}	{}	0	0	game	2026-02-23 12:08:48.808458-05
7	14	1771866511562.974	紫雷肩甲·仙	shoulder	epic	{"health": 331, "defense": 30, "counterRate": 0.07}	{}	0	0	game	2026-02-23 12:08:49.0384-05
8	14	1771866516182.184	星铁手套·仙	hands	epic	{"attack": 30, "critRate": 0.03, "comboRate": 0.11}	{}	0	0	game	2026-02-23 12:08:49.249878-05
9	14	1771866514758.2183	赤铜护腕·仙	wrist	epic	{"defense": 21, "counterRate": 0.11, "vampireRate": 0.12}	{}	0	0	game	2026-02-23 12:08:49.534625-05
10	14	1771866513233.992	云珠焰心链·仙	necklace	epic	{"health": 435, "healBoost": 0.19, "spiritRate": 0.18}	{}	0	0	game	2026-02-23 12:08:49.759665-05
11	14	1771866517625.5708	星命符文戒1·仙	ring1	epic	{"attack": 31, "critDamageBoost": 0.14, "finalDamageBoost": 0.09}	{}	0	0	game	2026-02-23 12:08:49.988918-05
12	14	1771866518856.9329	赤道符文戒2·仙	ring2	epic	{"defense": 51, "resistanceBoost": 0.15, "critDamageReduce": 0.14}	{}	0	0	game	2026-02-23 12:08:50.195362-05
13	16	1771866952781.0637	玄阳衣服·仙	body	epic	{"health": 417, "defense": 60, "finalDamageReduce": 0.45}	{}	0	0	game	2026-02-23 12:19:42.241232-05
14	16	1771867244264.336	云霄头部·天	head	rare	{"health": 399, "defense": 30, "stunResist": 0.35}	{}	0	0	game	2026-02-23 12:21:03.700472-05
15	16	1771867244264.4216	玄阳衣服·仙	body	epic	{"health": 1036, "defense": 89, "finalDamageReduce": 0.57}	{}	0	0	game	2026-02-23 12:21:04.079152-05
16	16	1771867244264.1338	紫电裤子·仙	legs	epic	{"speed": 57, "defense": 108, "dodgeRate": 0.1}	{}	0	0	game	2026-02-23 12:21:04.496769-05
17	16	1771867244264.7131	星步鞋子·仙	feet	epic	{"speed": 140, "defense": 62, "dodgeRate": 0.13}	{}	0	0	game	2026-02-23 12:21:04.999768-05
18	16	1771867244264.3662	赤羽肩甲·道	shoulder	uncommon	{"health": 263, "defense": 24, "counterRate": 0.04}	{}	0	0	game	2026-02-23 12:21:05.327867-05
19	16	1771867244264.5413	青钢手套·圣	hands	legendary	{"attack": 110, "critRate": 0.19, "comboRate": 0.26}	{}	0	0	game	2026-02-23 12:21:05.710261-05
20	16	1771867244264.9412	赤铜护腕·仙	wrist	epic	{"defense": 35, "counterRate": 0.22, "vampireRate": 0.27}	{}	0	0	game	2026-02-23 12:21:06.068207-05
21	16	1771867244264.989	幽魄焰心链·道	necklace	uncommon	{"health": 354, "healBoost": 0.11, "spiritRate": 0.13}	{}	0	0	game	2026-02-23 12:21:06.390685-05
22	16	1771867244264.4104	云命符文戒1·神	ring1	mythic	{"attack": 207, "critDamageBoost": 0.64, "finalDamageBoost": 0.69}	{}	0	0	game	2026-02-23 12:21:06.800773-05
23	16	1771867244264.6055	赤道符文戒2·神	ring2	mythic	{"defense": 117, "resistanceBoost": 0.57, "critDamageReduce": 0.86}	{}	0	0	game	2026-02-23 12:21:07.789345-05
24	16	1771867244264.287	幽系腰带·道	belt	uncommon	{"health": 260, "defense": 14, "combatBoost": 0.03}	{}	0	0	game	2026-02-23 12:21:08.189331-05
25	16	1771867244264.421	天宝焰器·天	artifact	rare	{"attack": 43, "critRate": 0.15, "comboRate": 0.15}	{}	0	0	game	2026-02-23 12:21:08.607434-05
\.


--
-- Data for Name: leaderboard_cache; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.leaderboard_cache (id, type, data, updated_at) FROM stdin;
1053	level	[{"name": "疯狂的小三", "rank": 1, "level": 16, "realm": "铸炉七重", "score": 16, "wallet": "0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5", "vip_level": 0, "combat_power": 9727, "total_recharge": "0.00000000"}, {"name": "无名焰修", "rank": 2, "level": 5, "realm": "燃火五重", "score": 5, "wallet": "0x82e402b05f3e936b63a874788c73e1552657c4f7", "vip_level": 0, "combat_power": 3827, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 3, "level": 1, "realm": "燃火期一层", "score": 1, "wallet": "0xc385d64735689929311621f4e81ca5b4e7830055", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}]	2026-02-24 22:05:42.958237
1054	combat_power	[{"name": "疯狂的小三", "rank": 1, "level": 16, "realm": "铸炉七重", "score": "9727", "wallet": "0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5", "vip_level": 0, "combat_power": 9727, "total_recharge": "0.00000000"}, {"name": "无名焰修", "rank": 2, "level": 5, "realm": "燃火五重", "score": "3827", "wallet": "0x82e402b05f3e936b63a874788c73e1552657c4f7", "vip_level": 0, "combat_power": 3827, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 3, "level": 1, "realm": "燃火期一层", "score": "0", "wallet": "0xc385d64735689929311621f4e81ca5b4e7830055", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}]	2026-02-24 22:05:42.961783
1055	recharge	[{"name": "无名修士", "rank": 1, "level": 1, "realm": "燃火期一层", "score": "0.00000000", "wallet": "0xc385d64735689929311621f4e81ca5b4e7830055", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "无名焰修", "rank": 2, "level": 5, "realm": "燃火五重", "score": "0.00000000", "wallet": "0x82e402b05f3e936b63a874788c73e1552657c4f7", "vip_level": 0, "combat_power": 3827, "total_recharge": "0.00000000"}, {"name": "疯狂的小三", "rank": 3, "level": 16, "realm": "铸炉七重", "score": "0.00000000", "wallet": "0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5", "vip_level": 0, "combat_power": 9727, "total_recharge": "0.00000000"}]	2026-02-24 22:05:42.963817
\.


--
-- Data for Name: login_logs; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.login_logs (id, wallet, ip, user_agent, created_at) FROM stdin;
1	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 07:51:37.503543
2	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 07:54:18.119081
3	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 07:55:08.111057
4	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 07:57:10.267853
5	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 07:57:37.068915
6	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 08:08:15.630264
7	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 08:56:59.761215
8	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 09:46:12.53609
9	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 10:13:12.7809
10	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 10:14:52.168996
11	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 10:29:32.248373
12	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 11:02:18.486157
13	0x82e402b05f3e936b63a874788c73e1552657c4f7	168.151.20.74	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	2026-02-23 11:14:49.667681
14	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 11:20:53.960335
15	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 11:25:01.802137
16	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 11:34:20.504648
17	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 11:35:16.858815
18	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 11:35:48.178029
19	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 11:41:14.034176
20	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 11:47:54.733904
21	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 11:55:52.97756
22	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 12:04:58.506225
23	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 12:09:43.591154
24	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 12:31:27.964351
25	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 12:36:16.73697
26	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 13:36:54.16684
27	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 13:38:39.641996
28	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 13:40:03.502856
\.


--
-- Data for Name: monthly_cards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.monthly_cards (id, wallet, purchased_at, expires_at, last_claim_date, days_claimed) FROM stdin;
\.


--
-- Data for Name: mounts; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.mounts (id, name, description, quality, emoji, attack_bonus, defense_bonus, health_bonus, speed_bonus, special_effect, obtain_method, created_at) FROM stdin;
1	白鹤	仙风道骨的白鹤，初学者的良伴	common	🦢	0.02	0.02	0.03	0.05	修炼速度+5%	新手赠送	2026-02-18 07:28:37.3665
2	赤焰马	浑身燃烧烈焰的骏马	rare	🐎	0.05	0.03	0.05	0.1	攻击附带火焰伤害	商城购买(10000灵石)	2026-02-18 07:28:37.3665
3	墨龙	远古墨龙后裔，威严霸气	epic	🐉	0.1	0.08	0.1	0.15	全属性+5%	世界Boss击杀奖励	2026-02-18 07:28:37.3665
4	九色鹿	传说中的瑞兽，带来好运	legendary	🦌	0.12	0.12	0.15	0.12	掉落率+20%	限时活动	2026-02-18 07:28:37.3665
5	鲲鹏	北冥有鱼，化而为鹏	mythic	🦅	0.2	0.15	0.2	0.25	全属性+15%，修炼速度+20%	飞升成仙	2026-02-18 07:28:37.3665
\.


--
-- Data for Name: pets; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.pets (id, owner_id, name, description, rarity, level, star, combat_attributes, is_active, created_at) FROM stdin;
\.


--
-- Data for Name: pk_rankings; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.pk_rankings (id, wallet, rank_score, rank_tier, season, wins, losses, draws, win_streak, max_win_streak, last_pk_at, created_at, updated_at) FROM stdin;
1	0x82e402b05f3e936b63a874788c73e1552657c4f7	1000	silver	1	0	0	0	0	0	\N	2026-02-23 12:36:33.112909-05	2026-02-23 12:36:33.112909-05
\.


--
-- Data for Name: pk_records; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pk_records (id, wallet_a, wallet_b, name_a, name_b, winner, winner_wallet, rounds_data, reward, created_at, bet_amount, score_change_a, score_change_b) FROM stdin;
1	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	0x82e402b05f3e936b63a874788c73e1552657c4f7	疯狂的小三	无名焰修	A	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	[{"hpA": 777, "hpB": 34, "round": 1, "actions": [{"damage": 166, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}, {"damage": 13, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}]}, {"hpA": 777, "hpB": 0, "round": 2, "actions": [{"damage": 166, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}]	500	2026-02-23 11:48:47.511912-05	0	0	0
2	0x82e402b05f3e936b63a874788c73e1552657c4f7	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	无名焰修	疯狂的小三	B	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	[{"hpA": 34, "hpB": 777, "round": 1, "actions": [{"damage": 166, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 13, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 34, "hpB": 764, "round": 2, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 13, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 0, "hpB": 764, "round": 3, "actions": [{"damage": 166, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}]}]	500	2026-02-23 11:51:54.676078-05	0	0	0
3	0x82e402b05f3e936b63a874788c73e1552657c4f7	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	无名焰修	疯狂的小三	B	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	[{"hpA": 34, "hpB": 777, "round": 1, "actions": [{"damage": 166, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 13, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 0, "hpB": 777, "round": 2, "actions": [{"damage": 166, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}]}]	500	2026-02-23 11:54:25.205253-05	0	0	0
4	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	0x82e402b05f3e936b63a874788c73e1552657c4f7	疯狂的小三	无名焰修	A	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	[{"hpA": 777, "hpB": 34, "round": 1, "actions": [{"damage": 166, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}, {"damage": 13, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}]}, {"hpA": 777, "hpB": 0, "round": 2, "actions": [{"damage": 166, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}]	500	2026-02-23 11:56:18.94177-05	0	0	0
5	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	0x82e402b05f3e936b63a874788c73e1552657c4f7	疯狂的小三	无名焰修	A	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	[{"hpA": 857, "hpB": 122, "round": 1, "actions": [{"damage": 78, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}, {"damage": 13, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}]}, {"hpA": 844, "hpB": 44, "round": 2, "actions": [{"damage": 78, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}, {"damage": 13, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}]}, {"hpA": 844, "hpB": 0, "round": 3, "actions": [{"damage": 78, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}]	500	2026-02-23 11:58:08.131647-05	0	0	0
6	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	0x82e402b05f3e936b63a874788c73e1552657c4f7	疯狂的小三	无名焰修	A	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	[{"hpA": 857, "hpB": 122, "round": 1, "actions": [{"damage": 78, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}, {"damage": 13, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}]}, {"hpA": 844, "hpB": 122, "round": 2, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": true}, {"damage": 13, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}]}, {"hpA": 831, "hpB": 44, "round": 3, "actions": [{"damage": 78, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}, {"damage": 13, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}]}, {"hpA": 831, "hpB": 0, "round": 4, "actions": [{"damage": 117, "isCrit": true, "isCombo": false, "attacker": "A", "isDodged": false}]}]	500	2026-02-23 12:05:52.060934-05	0	0	0
7	0x82e402b05f3e936b63a874788c73e1552657c4f7	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	无名焰修	疯狂的小三	B	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	[{"hpA": 83, "hpB": 857, "round": 1, "actions": [{"damage": 117, "isCrit": true, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 13, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 5, "hpB": 844, "round": 2, "actions": [{"damage": 78, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 13, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 0, "hpB": 844, "round": 3, "actions": [{"damage": 78, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}]}]	500	2026-02-23 12:06:26.742496-05	0	0	0
8	0x82e402b05f3e936b63a874788c73e1552657c4f7	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	无名焰修	疯狂的小三	A	0x82e402b05f3e936b63a874788c73e1552657c4f7	[{"hpA": 2032, "hpB": 741, "round": 1, "actions": [{"damage": 129, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}, {"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}]}, {"hpA": 2019, "hpB": 553, "round": 2, "actions": [{"damage": 129, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}, {"damage": 13, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 59, "attacker": "A", "isCounter": true}]}, {"hpA": 2019, "hpB": 365, "round": 3, "actions": [{"damage": 129, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}, {"damage": 13, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 59, "attacker": "A", "isCounter": true}]}, {"hpA": 2019, "hpB": 197, "round": 4, "actions": [{"damage": 168, "isCrit": false, "isCombo": true, "attacker": "A", "isDodged": false}, {"damage": 13, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}]}, {"hpA": 2019, "hpB": 68, "round": 5, "actions": [{"damage": 129, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}, {"damage": 13, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}]}, {"hpA": 2032, "hpB": 0, "round": 6, "actions": [{"damage": 129, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}]	500	2026-02-23 12:10:02.044702-05	0	0	0
9	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	0x82e402b05f3e936b63a874788c73e1552657c4f7	疯狂的小三	无名焰修	B	0x82e402b05f3e936b63a874788c73e1552657c4f7	[{"hpA": 741, "hpB": 1982, "round": 1, "actions": [{"damage": 129, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 50, "isCrit": true, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 612, "hpB": 1968, "round": 2, "actions": [{"damage": 129, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 29, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 483, "hpB": 1954, "round": 3, "actions": [{"damage": 129, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 29, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 295, "hpB": 1919, "round": 4, "actions": [{"damage": 129, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 50, "isCrit": true, "isCombo": false, "attacker": "A", "isDodged": false}, {"damage": 59, "attacker": "B", "isCounter": true}]}, {"hpA": 166, "hpB": 1905, "round": 5, "actions": [{"damage": 129, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 29, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 37, "hpB": 1891, "round": 6, "actions": [{"damage": 129, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 29, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 0, "hpB": 1906, "round": 7, "actions": [{"damage": 129, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}]}]	500	2026-02-23 12:11:23.941875-05	0	0	0
\.


--
-- Data for Name: player_mail; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.player_mail (id, to_wallet, from_type, from_name, title, content, rewards, is_read, is_claimed, expires_at, created_at, from_wallet) FROM stdin;
29	0x82e402b05f3e936b63a874788c73e1552657c4f7	system	系统	🔥 欢迎来到火之文明！	欢迎加入焰修世界！🧪 内测期间赠送100,000焰晶，祝你修炼顺利！提示：1.先去修炼积累焰力 2.去探索获取资源 3.去焰运阁抽装备 4.记得每日签到！	{"spiritStones": 110000, "reinforceStones": 20}	t	t	\N	2026-02-23 07:51:37.48624-05	\N
30	0xc385d64735689929311621f4e81ca5b4e7830055	system	系统	🔥 欢迎来到火之文明！	欢迎加入焰修世界！🧪 内测期间赠送100,000焰晶，祝你修炼顺利！提示：1.先去修炼积累焰力 2.去探索获取资源 3.去焰运阁抽装备 4.记得每日签到！	{"spiritStones": 110000, "reinforceStones": 20}	t	t	\N	2026-02-23 07:54:18.111863-05	\N
31	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	system	系统	🔥 欢迎来到火之文明！	欢迎加入焰修世界！🧪 内测期间赠送100,000焰晶，祝你修炼顺利！提示：1.先去修炼积累焰力 2.去探索获取资源 3.去焰运阁抽装备 4.记得每日签到！	{"spiritStones": 110000, "reinforceStones": 20}	t	t	\N	2026-02-23 07:57:37.065333-05	\N
\.


--
-- Data for Name: player_mounts; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.player_mounts (id, wallet, mount_id, level, exp, is_active, obtained_at) FROM stdin;
\.


--
-- Data for Name: player_stats_snapshot; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.player_stats_snapshot (player_id, state_version, final_stats, computed_at) FROM stdin;
16	230	{"speed": 241, "attack": 568, "damage": 568, "health": 3292, "defense": 539, "critRate": 0.5900000000000001, "stunRate": 0.06, "comboRate": 0.47000000000000003, "dodgeRate": 0.29000000000000004, "healBoost": 0.16999999999999998, "maxHealth": 3292, "critResist": 0.06, "spiritRate": 1.13, "stunResist": 0.41, "combatBoost": 0.09, "comboResist": 0.06, "counterRate": 0.32, "dodgeResist": 0.06, "vampireRate": 0.33, "counterResist": 0.06, "vampireResist": 0.06, "critDamageBoost": 1.02, "cultivationRate": 1, "resistanceBoost": 0.6299999999999999, "critDamageReduce": 0.9199999999999999, "finalDamageBoost": 0.75, "finalDamageReduce": 0.6299999999999999}	2026-02-23 12:37:21.415-05
14	74	{"speed": 87, "attack": 181, "damage": 181, "health": 2032, "defense": 289, "critRate": 0.13, "stunRate": 0, "comboRate": 0.11, "dodgeRate": 0.21, "healBoost": 0.19, "maxHealth": 2032, "critResist": 0, "spiritRate": 1.18, "stunResist": 0.41, "combatBoost": 0, "comboResist": 0, "counterRate": 0.18, "dodgeResist": 0, "vampireRate": 0.12, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0.29000000000000004, "cultivationRate": 1, "resistanceBoost": 0.15, "critDamageReduce": 0.14, "finalDamageBoost": 0.09, "finalDamageReduce": 0.29}	2026-02-23 12:37:21.43-05
\.


--
-- Data for Name: player_titles; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.player_titles (id, wallet, title_id, is_active, obtained_at) FROM stdin;
\.


--
-- Data for Name: players; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.players (id, wallet, name, game_data, vip_level, total_recharge, spirit_stones, level, realm, combat_power, first_recharge, daily_sign_date, daily_sign_streak, created_at, updated_at, banned, state_version) FROM stdin;
15	0xc385d64735689929311621f4e81ca5b4e7830055	无名修士	{"level": 1, "spirit": 147.405, "_nakedBase": {"speed": 10, "attack": 10, "health": 100, "defense": 5}, "lastTickTime": 1771851443894, "spiritStones": 110000, "baseAttributes": {"speed": 10, "attack": 10, "health": 100, "defense": 5}, "lastOnlineTime": 1771851443894, "artifactBonuses": {"speed": 0, "attack": 0, "health": 0, "defense": 0, "critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "healBoost": 0, "critResist": 0, "spiritRate": 0, "stunResist": 0, "combatBoost": 0, "comboResist": 0, "counterRate": 0, "dodgeResist": 0, "vampireRate": 0, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0, "cultivationRate": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "reinforceStones": 20, "combatAttributes": {"critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "counterRate": 0, "vampireRate": 0}, "combatResistance": {"critResist": 0, "stunResist": 0, "comboResist": 0, "dodgeResist": 0, "counterResist": 0, "vampireResist": 0}, "equippedArtifacts": {}, "specialAttributes": {"healBoost": 0, "combatBoost": 0, "critDamageBoost": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}}	0	0.00000000	110000	1	燃火期一层	0	f	\N	0	2026-02-23 07:54:18.108913	2026-02-23 07:57:23.895021	f	0
14	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名焰修	{"luck": 1, "name": "无名焰修", "buffs": {}, "herbs": [], "items": [], "level": 5, "pills": [], "realm": "燃火五重", "spirit": 700, "herbRate": 1, "isGMMode": false, "vipLevel": 0, "activePet": null, "artifacts": [], "petConfig": {"rarityMap": {"divine": {"name": "神品", "color": "#FF0000", "probability": 0.02, "essenceBonus": 50}, "mortal": {"name": "凡品", "color": "#32CD32", "probability": 0.5, "essenceBonus": 5}, "mystic": {"name": "玄品", "color": "#9932CC", "probability": 0.15, "essenceBonus": 20}, "celestial": {"name": "仙品", "color": "#FFD700", "probability": 0.08, "essenceBonus": 30}, "spiritual": {"name": "灵品", "color": "#1E90FF", "probability": 0.25, "essenceBonus": 10}}}, "_nakedBase": {"speed": 18, "attack": 30, "health": 300, "defense": 17}, "isDarkMode": false, "itemsFound": 0, "petEssence": 0, "spiritRate": 1, "alchemyRate": 1, "cultivation": 0, "isNewPlayer": true, "pillRecipes": [], "lastTickTime": 1771988701636, "pillsCrafted": 0, "spiritStones": 4745, "activeEffects": [], "pillFragments": {}, "pillsConsumed": 0, "storageExpand": {}, "baseAttributes": {"speed": 89, "attack": 186, "health": 2082, "defense": 292}, "eventTriggered": 0, "lastOnlineTime": 1771947747318, "maxCultivation": 600, "unlockedRealms": ["燃火一层", "燃火五重"], "unlockedSkills": [], "artifactBonuses": {"speed": 71, "attack": 156, "health": 1782, "defense": 275, "critRate": 0.13, "stunRate": 0, "comboRate": 0.11, "dodgeRate": 0.21, "healBoost": 0.19, "critResist": 0, "spiritRate": 0.18, "stunResist": 0.41, "combatBoost": 0, "comboResist": 0, "counterRate": 0.18, "dodgeResist": 0, "vampireRate": 0.12, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0.29000000000000004, "cultivationRate": 0, "resistanceBoost": 0.15, "critDamageReduce": 0.14, "finalDamageBoost": 0.09, "finalDamageReduce": 0.29}, "cultivationRate": 1, "nameChangeCount": 0, "reinforceStones": 20, "wishlistEnabled": false, "activeMountBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "activeTitleBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "combatAttributes": {"critRate": 0.13, "stunRate": 0, "comboRate": 0.11, "dodgeRate": 0.21, "counterRate": 0.18, "vampireRate": 0.12}, "combatResistance": {"critResist": 0, "stunResist": 0.41, "comboResist": 0, "dodgeResist": 0, "counterResist": 0, "vampireResist": 0}, "dungeonBossKills": 0, "dungeonTotalRuns": 0, "explorationCount": 0, "refinementStones": 0, "autoSellQualities": [], "breakthroughCount": 4, "dungeonDeathCount": 0, "dungeonDifficulty": 1, "dungeonEliteKills": 0, "dungeonTotalKills": 0, "equippedArtifacts": {"body": {"id": 1771866504562.0095, "name": "太素衣服·仙", "slot": "body", "type": "body", "level": 3, "stats": {"health": 543, "defense": 59, "finalDamageReduce": 0.29}, "quality": "epic", "equipType": "body", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 3}, "feet": {"id": 1771866509747.372, "name": "幽影鞋子·仙", "slot": "feet", "type": "feet", "level": 3, "stats": {"speed": 37, "defense": 23, "dodgeRate": 0.12}, "quality": "epic", "equipType": "feet", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 3}, "head": {"id": 1771866506468.2437, "name": "玄冥头部·仙", "slot": "head", "type": "head", "level": 3, "stats": {"health": 473, "defense": 44, "stunResist": 0.41}, "quality": "epic", "equipType": "head", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 3}, "legs": {"id": 1771866508146.2104, "name": "紫电裤子·仙", "slot": "legs", "type": "legs", "level": 3, "stats": {"speed": 34, "defense": 47, "dodgeRate": 0.09}, "quality": "epic", "equipType": "legs", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 3}, "hands": {"id": 1771866516182.184, "name": "星铁手套·仙", "slot": "hands", "type": "hands", "level": 3, "stats": {"attack": 30, "critRate": 0.03, "comboRate": 0.11}, "quality": "epic", "equipType": "hands", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 3}, "ring1": {"id": 1771866517625.5708, "name": "星命符文戒1·仙", "slot": "ring1", "type": "ring1", "level": 3, "stats": {"attack": 31, "critDamageBoost": 0.14, "finalDamageBoost": 0.09}, "quality": "epic", "equipType": "ring1", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 3}, "ring2": {"id": 1771866518856.9329, "name": "赤道符文戒2·仙", "slot": "ring2", "type": "ring2", "level": 3, "stats": {"defense": 51, "resistanceBoost": 0.15, "critDamageReduce": 0.14}, "quality": "epic", "equipType": "ring2", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 3}, "wrist": {"id": 1771866514758.2183, "name": "赤铜护腕·仙", "slot": "wrist", "type": "wrist", "level": 3, "stats": {"defense": 21, "counterRate": 0.11, "vampireRate": 0.12}, "quality": "epic", "equipType": "wrist", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 3}, "weapon": {"id": 1771866494846.1091, "name": "赤炎焰杖·圣", "slot": "weapon", "type": "weapon", "level": 3, "stats": {"attack": 95, "critRate": 0.1, "critDamageBoost": 0.15}, "quality": "legendary", "equipType": "weapon", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 6, "maxStatMod": 8}, "requiredRealm": 3}, "necklace": {"id": 1771866513233.992, "name": "云珠焰心链·仙", "slot": "necklace", "type": "necklace", "level": 3, "stats": {"health": 435, "healBoost": 0.19, "spiritRate": 0.18}, "quality": "epic", "equipType": "necklace", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 3}, "shoulder": {"id": 1771866511562.974, "name": "紫雷肩甲·仙", "slot": "shoulder", "type": "shoulder", "level": 3, "stats": {"health": 331, "defense": 30, "counterRate": 0.07}, "quality": "epic", "equipType": "shoulder", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 3}}, "isAutoCultivating": false, "specialAttributes": {"healBoost": 0.19, "combatBoost": 0, "critDamageBoost": 0.29000000000000004, "resistanceBoost": 0.15, "critDamageReduce": 0.14, "finalDamageBoost": 0.09, "finalDamageReduce": 0.29}, "unlockedLocations": ["新手村"], "autoReleaseRarities": [], "dungeonHighestFloor": 0, "dungeonTotalRewards": 0, "shopWeeklyPurchases": {"legendary": {"count": 1, "weekStart": 1771804800000}}, "unlockedPillRecipes": 0, "totalCultivationTime": 0, "completedAchievements": [], "dungeonHighestFloor_2": 0, "dungeonHighestFloor_5": 0, "selectedWishPetRarity": null, "dungeonHighestFloor_10": 0, "dungeonLastFailedFloor": 0, "dungeonHighestFloor_100": 0, "selectedWishEquipQuality": null}	0	0.00000000	4745	5	燃火五重	3827	f	2026-02-23	1	2026-02-23 07:51:37.47891	2026-02-24 22:05:01.638122	f	92
16	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	疯狂的小三	{"luck": 1, "name": "疯狂的小三", "buffs": {}, "herbs": [], "items": [{"id": 1771867244264.1338, "name": "青玉头部·道", "slot": "head", "type": "head", "level": 13, "stats": {"health": 310, "defense": 31, "stunResist": 0.3}, "quality": "uncommon", "category": "equipment", "equipType": "head", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.5, "maxStatMod": 2}, "requiredRealm": 13}, {"id": 1771867255186.1768, "name": "岩龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 4, "strength": 2, "constitution": 2, "intelligence": 1}, "experience": 0, "description": "坚不可摧的守护者", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 25, "attack": 32, "health": 342, "defense": 18, "critRate": 0.12, "stunRate": 0.13, "comboRate": 0.11, "dodgeRate": 0.1, "healBoost": 0.14, "critResist": 0.14, "stunResist": 0.1, "combatBoost": 0.11, "comboResist": 0.1, "counterRate": 0.14, "dodgeResist": 0.1, "vampireRate": 0.14, "counterResist": 0.14, "vampireResist": 0.13, "critDamageBoost": 0.15, "resistanceBoost": 0.09, "critDamageReduce": 0.15, "finalDamageBoost": 0.1, "finalDamageReduce": 0.16}}, {"id": 1771867255186.463, "name": "负屃", "star": 0, "type": "pet", "level": 14, "power": 0, "rarity": "celestial", "quality": {"agility": 4, "strength": 7, "constitution": 6, "intelligence": 9}, "experience": 0, "description": "龙之八子，形似龙，雅好诗文，常盘于碑顶", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 30, "attack": 45, "health": 503, "defense": 23, "critRate": 0.13, "stunRate": 0.11, "comboRate": 0.18, "dodgeRate": 0.11, "healBoost": 0.1, "critResist": 0.15, "stunResist": 0.13, "combatBoost": 0.14, "comboResist": 0.1, "counterRate": 0.18, "dodgeResist": 0.16, "vampireRate": 0.15, "counterResist": 0.12, "vampireResist": 0.15, "critDamageBoost": 0.13, "resistanceBoost": 0.17, "critDamageReduce": 0.15, "finalDamageBoost": 0.15, "finalDamageReduce": 0.17}}, {"id": 1771867255186.8516, "name": "火凤凰", "star": 2, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 1, "strength": 7, "constitution": 1, "intelligence": 7}, "experience": 0, "description": "浴火重生的永恒之鸟", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 27, "attack": 36, "health": 390, "defense": 24, "critRate": 0.12, "stunRate": 0.13, "comboRate": 0.12, "dodgeRate": 0.14, "healBoost": 0.14, "critResist": 0.09, "stunResist": 0.12, "combatBoost": 0.14, "comboResist": 0.13, "counterRate": 0.08, "dodgeResist": 0.14, "vampireRate": 0.15, "counterResist": 0.12, "vampireResist": 0.16, "critDamageBoost": 0.09, "resistanceBoost": 0.15, "critDamageReduce": 0.15, "finalDamageBoost": 0.15, "finalDamageReduce": 0.15}}, {"id": 1771867255186.664, "name": "雷鹰", "star": 1, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 5, "strength": 10, "constitution": 5, "intelligence": 3}, "experience": 0, "description": "雷电的猛禽", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 26, "attack": 39, "health": 327, "defense": 18, "critRate": 0.09, "stunRate": 0.12, "comboRate": 0.15, "dodgeRate": 0.14, "healBoost": 0.12, "critResist": 0.13, "stunResist": 0.14, "combatBoost": 0.16, "comboResist": 0.15, "counterRate": 0.11, "dodgeResist": 0.1, "vampireRate": 0.15, "counterResist": 0.15, "vampireResist": 0.14, "critDamageBoost": 0.16, "resistanceBoost": 0.15, "critDamageReduce": 0.09, "finalDamageBoost": 0.09, "finalDamageReduce": 0.16}}, {"id": 1771867255186.484, "name": "冰狼", "star": 1, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 9, "strength": 5, "constitution": 9, "intelligence": 10}, "experience": 0, "description": "冰原霸主", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 24, "attack": 40, "health": 362, "defense": 19, "critRate": 0.14, "stunRate": 0.15, "comboRate": 0.16, "dodgeRate": 0.14, "healBoost": 0.13, "critResist": 0.11, "stunResist": 0.13, "combatBoost": 0.13, "comboResist": 0.13, "counterRate": 0.14, "dodgeResist": 0.12, "vampireRate": 0.08, "counterResist": 0.13, "vampireResist": 0.15, "critDamageBoost": 0.11, "resistanceBoost": 0.11, "critDamageReduce": 0.09, "finalDamageBoost": 0.15, "finalDamageReduce": 0.16}}, {"id": 1771867255186.8772, "name": "狴犴", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "celestial", "quality": {"agility": 8, "strength": 3, "constitution": 6, "intelligence": 4}, "experience": 0, "description": "龙之七子，形似虎，明辨是非，常立于狱门", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 27, "attack": 45, "health": 449, "defense": 29, "critRate": 0.09, "stunRate": 0.12, "comboRate": 0.1, "dodgeRate": 0.18, "healBoost": 0.17, "critResist": 0.13, "stunResist": 0.15, "combatBoost": 0.11, "comboResist": 0.13, "counterRate": 0.18, "dodgeResist": 0.18, "vampireRate": 0.17, "counterResist": 0.16, "vampireResist": 0.17, "critDamageBoost": 0.11, "resistanceBoost": 0.16, "critDamageReduce": 0.11, "finalDamageBoost": 0.16, "finalDamageReduce": 0.17}}, {"id": 1771867255186.072, "name": "冰狼", "star": 2, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 2, "strength": 10, "constitution": 9, "intelligence": 4}, "experience": 0, "description": "冰原霸主", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 26, "attack": 41, "health": 330, "defense": 17, "critRate": 0.16, "stunRate": 0.15, "comboRate": 0.15, "dodgeRate": 0.15, "healBoost": 0.15, "critResist": 0.13, "stunResist": 0.14, "combatBoost": 0.14, "comboResist": 0.09, "counterRate": 0.12, "dodgeResist": 0.09, "vampireRate": 0.09, "counterResist": 0.09, "vampireResist": 0.15, "critDamageBoost": 0.14, "resistanceBoost": 0.09, "critDamageReduce": 0.09, "finalDamageBoost": 0.09, "finalDamageReduce": 0.13}}, {"id": 1771867255186.9873, "name": "火凤凰", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 8, "strength": 4, "constitution": 8, "intelligence": 7}, "experience": 0, "description": "浴火重生的永恒之鸟", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 22, "attack": 40, "health": 359, "defense": 17, "critRate": 0.15, "stunRate": 0.11, "comboRate": 0.12, "dodgeRate": 0.11, "healBoost": 0.09, "critResist": 0.1, "stunResist": 0.15, "combatBoost": 0.1, "comboResist": 0.1, "counterRate": 0.12, "dodgeResist": 0.12, "vampireRate": 0.13, "counterResist": 0.11, "vampireResist": 0.11, "critDamageBoost": 0.16, "resistanceBoost": 0.13, "critDamageReduce": 0.08, "finalDamageBoost": 0.09, "finalDamageReduce": 0.14}}, {"id": 1771867255186.0151, "name": "螭吻", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "celestial", "quality": {"agility": 9, "strength": 7, "constitution": 1, "intelligence": 10}, "experience": 0, "description": "龙之九子，形似鱼，能吞火，常立于屋脊", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 33, "attack": 48, "health": 446, "defense": 21, "critRate": 0.16, "stunRate": 0.15, "comboRate": 0.12, "dodgeRate": 0.11, "healBoost": 0.1, "critResist": 0.15, "stunResist": 0.12, "combatBoost": 0.14, "comboResist": 0.18, "counterRate": 0.18, "dodgeResist": 0.14, "vampireRate": 0.14, "counterResist": 0.16, "vampireResist": 0.12, "critDamageBoost": 0.1, "resistanceBoost": 0.16, "critDamageReduce": 0.15, "finalDamageBoost": 0.1, "finalDamageReduce": 0.11}}, {"id": 1771867255186.159, "name": "冰狼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 8, "strength": 3, "constitution": 1, "intelligence": 9}, "experience": 0, "description": "冰原霸主", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 23, "attack": 43, "health": 331, "defense": 16, "critRate": 0.11, "stunRate": 0.14, "comboRate": 0.14, "dodgeRate": 0.14, "healBoost": 0.15, "critResist": 0.12, "stunResist": 0.13, "combatBoost": 0.11, "comboResist": 0.12, "counterRate": 0.1, "dodgeResist": 0.11, "vampireRate": 0.12, "counterResist": 0.14, "vampireResist": 0.13, "critDamageBoost": 0.16, "resistanceBoost": 0.1, "critDamageReduce": 0.1, "finalDamageBoost": 0.11, "finalDamageReduce": 0.09}}, {"id": 1771867255186.0483, "name": "雷鹰", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 9, "strength": 7, "constitution": 10, "intelligence": 10}, "experience": 0, "description": "雷电的猛禽", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 24, "attack": 37, "health": 318, "defense": 21, "critRate": 0.13, "stunRate": 0.16, "comboRate": 0.08, "dodgeRate": 0.1, "healBoost": 0.1, "critResist": 0.13, "stunResist": 0.15, "combatBoost": 0.08, "comboResist": 0.11, "counterRate": 0.14, "dodgeResist": 0.1, "vampireRate": 0.13, "counterResist": 0.08, "vampireResist": 0.08, "critDamageBoost": 0.11, "resistanceBoost": 0.15, "critDamageReduce": 0.15, "finalDamageBoost": 0.11, "finalDamageReduce": 0.09}}, {"id": 1771867255186.2168, "name": "岩龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 4, "strength": 8, "constitution": 7, "intelligence": 3}, "experience": 0, "description": "坚不可摧的守护者", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 27, "attack": 40, "health": 356, "defense": 16, "critRate": 0.09, "stunRate": 0.13, "comboRate": 0.13, "dodgeRate": 0.16, "healBoost": 0.12, "critResist": 0.14, "stunResist": 0.16, "combatBoost": 0.14, "comboResist": 0.09, "counterRate": 0.11, "dodgeResist": 0.14, "vampireRate": 0.11, "counterResist": 0.14, "vampireResist": 0.15, "critDamageBoost": 0.16, "resistanceBoost": 0.13, "critDamageReduce": 0.11, "finalDamageBoost": 0.12, "finalDamageReduce": 0.09}}], "level": 16, "pills": [], "realm": "铸炉七重", "spirit": 1800, "herbRate": 1, "isGMMode": false, "vipLevel": 0, "activePet": {"id": 1771867255186.463, "name": "负屃", "star": 0, "type": "pet", "level": 14, "power": 0, "rarity": "celestial", "quality": {"agility": 4, "strength": 7, "constitution": 6, "intelligence": 9}, "experience": 0, "description": "龙之八子，形似龙，雅好诗文，常盘于碑顶", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 30, "attack": 45, "health": 503, "defense": 23, "critRate": 0.13, "stunRate": 0.11, "comboRate": 0.18, "dodgeRate": 0.11, "healBoost": 0.1, "critResist": 0.15, "stunResist": 0.13, "combatBoost": 0.14, "comboResist": 0.1, "counterRate": 0.18, "dodgeResist": 0.16, "vampireRate": 0.15, "counterResist": 0.12, "vampireResist": 0.15, "critDamageBoost": 0.13, "resistanceBoost": 0.17, "critDamageReduce": 0.15, "finalDamageBoost": 0.15, "finalDamageReduce": 0.17}}, "artifacts": [], "petConfig": {"rarityMap": {"divine": {"name": "神品", "color": "#FF0000", "probability": 0.02, "essenceBonus": 50}, "mortal": {"name": "凡品", "color": "#32CD32", "probability": 0.5, "essenceBonus": 5}, "mystic": {"name": "玄品", "color": "#9932CC", "probability": 0.15, "essenceBonus": 20}, "celestial": {"name": "仙品", "color": "#FFD700", "probability": 0.08, "essenceBonus": 30}, "spiritual": {"name": "灵品", "color": "#1E90FF", "probability": 0.25, "essenceBonus": 10}}}, "_nakedBase": {"speed": 46, "attack": 103, "health": 1030, "defense": 62}, "isDarkMode": false, "itemsFound": 0, "petEssence": 85, "spiritRate": 1, "alchemyRate": 1, "cultivation": 2784, "isNewPlayer": true, "pillRecipes": [], "pillsCrafted": 0, "spiritStones": 39000, "activeEffects": [], "pillFragments": {}, "pillsConsumed": 0, "storageExpand": {}, "baseAttributes": {"speed": 259.8, "attack": 678, "health": 3762, "defense": 583}, "eventTriggered": 0, "lastOnlineTime": 0, "maxCultivation": 2800, "unlockedRealms": ["燃火一层", "铸炉七重"], "unlockedSkills": [], "artifactBonuses": {"speed": 197, "attack": 477, "health": 2312, "defense": 479, "critRate": 0.55, "stunRate": 0, "comboRate": 0.15, "dodgeRate": 0.23, "healBoost": 0.11, "critResist": 0, "spiritRate": 0.13, "stunResist": 0.35, "combatBoost": 0.03, "comboResist": 0, "counterRate": 0.26, "dodgeResist": 0, "vampireRate": 0.27, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0.96, "cultivationRate": 0, "resistanceBoost": 0.57, "critDamageReduce": 0.86, "finalDamageBoost": 0.69, "finalDamageReduce": 0.57}, "cultivationRate": 1, "nameChangeCount": 1, "reinforceStones": 10, "wishlistEnabled": false, "activeMountBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "activeTitleBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "combatAttributes": {"critRate": 0.55, "stunRate": 0, "comboRate": 0.15, "dodgeRate": 0.23, "counterRate": 0.26, "vampireRate": 0.27}, "combatResistance": {"critResist": 0, "stunResist": 0.35, "comboResist": 0, "dodgeResist": 0, "counterResist": 0, "vampireResist": 0}, "dungeonBossKills": 1, "dungeonTotalRuns": 0, "explorationCount": 1, "refinementStones": 1, "autoSellQualities": [], "breakthroughCount": 15, "dungeonDeathCount": 0, "dungeonDifficulty": 1, "dungeonEliteKills": 1, "dungeonTotalKills": 14, "equippedArtifacts": {"belt": {"id": 1771867244264.287, "name": "幽系腰带·道", "slot": "belt", "type": "belt", "level": 12, "stats": {"health": 260, "defense": 14, "combatBoost": 0.03}, "quality": "uncommon", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.5, "maxStatMod": 2}, "requiredRealm": 12}, "body": {"id": 1771867244264.4216, "name": "玄阳衣服·仙", "slot": "body", "type": "body", "level": 8, "stats": {"health": 1036, "defense": 89, "finalDamageReduce": 0.57}, "quality": "epic", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 8}, "feet": {"id": 1771867244264.7131, "name": "星步鞋子·仙", "slot": "feet", "type": "feet", "level": 14, "stats": {"speed": 140, "defense": 62, "dodgeRate": 0.13}, "quality": "epic", "category": "equipment", "equipType": "feet", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 14}, "head": {"id": 1771867244264.336, "name": "云霄头部·天", "slot": "head", "type": "head", "level": 7, "stats": {"health": 399, "defense": 30, "stunResist": 0.35}, "quality": "rare", "category": "equipment", "equipType": "head", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 2.5, "maxStatMod": 3.5}, "requiredRealm": 7}, "legs": {"id": 1771867244264.1338, "name": "紫电裤子·仙", "slot": "legs", "type": "legs", "level": 14, "stats": {"speed": 57, "defense": 108, "dodgeRate": 0.1}, "quality": "epic", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 14}, "hands": {"id": 1771867244264.5413, "name": "青钢手套·圣", "slot": "hands", "type": "hands", "level": 10, "stats": {"attack": 121, "critRate": 0.21, "comboRate": 0}, "quality": "legendary", "category": "equipment", "equipType": "hands", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 6, "maxStatMod": 8}, "enhanceLevel": 1, "requiredRealm": 10}, "ring1": {"id": 1771867244264.4104, "name": "云命符文戒1·神", "slot": "ring1", "type": "ring1", "level": 15, "stats": {"attack": 207, "critDamageBoost": 0.64, "finalDamageBoost": 0.69}, "quality": "mythic", "category": "equipment", "equipType": "ring1", "qualityInfo": {"name": "仙品", "color": "#e91e63", "statMod": 10, "maxStatMod": 13}, "requiredRealm": 15}, "ring2": {"id": 1771867244264.6055, "name": "赤道符文戒2·神", "slot": "ring2", "type": "ring2", "level": 10, "stats": {"defense": 117, "resistanceBoost": 0.57, "critDamageReduce": 0.86}, "quality": "mythic", "category": "equipment", "equipType": "ring2", "qualityInfo": {"name": "仙品", "color": "#e91e63", "statMod": 10, "maxStatMod": 13}, "requiredRealm": 10}, "wrist": {"id": 1771867244264.9412, "name": "赤铜护腕·仙", "slot": "wrist", "type": "wrist", "level": 15, "stats": {"defense": 35, "counterRate": 0.22, "vampireRate": 0.27}, "quality": "epic", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 15}, "weapon": {"id": 1771863710323.9473, "name": "幽冥焰杖·圣", "slot": "weapon", "type": "weapon", "level": 13, "stats": {"attack": 106, "critRate": 0.19, "critDamageBoost": 0.32}, "quality": "legendary", "equipType": "weapon", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 6, "maxStatMod": 8}, "requiredRealm": 13}, "artifact": {"id": 1771867244264.421, "name": "天宝焰器·天", "slot": "artifact", "type": "artifact", "level": 12, "stats": {"attack": 43, "critRate": 0.15, "comboRate": 0.15}, "quality": "rare", "category": "equipment", "equipType": "artifact", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 2.5, "maxStatMod": 3.5}, "requiredRealm": 12}, "necklace": {"id": 1771867244264.989, "name": "幽魄焰心链·道", "slot": "necklace", "type": "necklace", "level": 11, "stats": {"health": 354, "healBoost": 0.11, "spiritRate": 0.13}, "quality": "uncommon", "category": "equipment", "equipType": "necklace", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.5, "maxStatMod": 2}, "requiredRealm": 11}, "shoulder": {"id": 1771867244264.3662, "name": "赤羽肩甲·道", "slot": "shoulder", "type": "shoulder", "level": 13, "stats": {"health": 263, "defense": 24, "counterRate": 0.04}, "quality": "uncommon", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.5, "maxStatMod": 2}, "requiredRealm": 13}}, "isAutoCultivating": false, "specialAttributes": {"healBoost": 0.11, "combatBoost": 0.03, "critDamageBoost": 0.96, "resistanceBoost": 0.57, "critDamageReduce": 0.86, "finalDamageBoost": 0.69, "finalDamageReduce": 0.57}, "unlockedLocations": ["新手村"], "autoReleaseRarities": [], "dungeonHighestFloor": 14, "dungeonTotalRewards": 1175, "shopWeeklyPurchases": {"legendary": {"count": 1, "weekStart": 1771804800000}}, "unlockedPillRecipes": 0, "totalCultivationTime": 0, "completedAchievements": [], "dungeonHighestFloor_2": 0, "dungeonHighestFloor_5": 0, "selectedWishPetRarity": null, "dungeonHighestFloor_10": 0, "dungeonLastFailedFloor": 0, "dungeonHighestFloor_100": 0, "selectedWishEquipQuality": null}	0	0.00000000	39999	16	铸炉七重	9727	f	2026-02-23	1	2026-02-23 07:57:37.062959	2026-02-23 13:40:14.648001	f	245
\.


--
-- Data for Name: private_messages; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.private_messages (id, from_wallet, to_wallet, content, is_read, created_at) FROM stdin;
\.


--
-- Data for Name: recharge_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.recharge_log (id, wallet, tx_hash, amount, spirit_stones, bonus_stones, created_at) FROM stdin;
\.


--
-- Data for Name: sect_members; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.sect_members (id, sect_id, wallet, role, contribution, joined_at) FROM stdin;
\.


--
-- Data for Name: sect_tasks; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.sect_tasks (id, sect_id, type, title, description, reward_contribution, reward_stones, completed_by, reset_at) FROM stdin;
\.


--
-- Data for Name: sect_war_participants; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.sect_war_participants (id, war_id, sect_id, wallet, player_name, combat_power, result, damage_dealt, round_number) FROM stdin;
\.


--
-- Data for Name: sect_war_rankings; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.sect_war_rankings (id, sect_id, season, wins, losses, points, updated_at) FROM stdin;
\.


--
-- Data for Name: sect_war_rewards; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.sect_war_rewards (id, war_id, sect_id, wallet, reward_stones, reward_contribution, claimed, created_at) FROM stdin;
\.


--
-- Data for Name: sect_wars; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.sect_wars (id, challenger_sect_id, defender_sect_id, status, challenger_score, defender_score, winner_sect_id, rounds_data, started_at, finished_at, created_at) FROM stdin;
\.


--
-- Data for Name: sects; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.sects (id, name, description, leader_wallet, level, exp, max_members, announcement, created_at) FROM stdin;
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.settings (key, value, updated_at) FROM stdin;
gacha_equip_probs	{"epic": 0.08, "rare": 0.18, "common": 0.4, "mythic": 0.005, "uncommon": 0.3, "legendary": 0.03}	2026-02-20 12:56:16.556656-05
shop_config	{"reinforce_stone": 1000, "reinforce_stone_10": 9000}	2026-02-21 13:09:22.328051-05
gacha_config	{"r_rate": 88.5, "sr_rate": 10, "ssr_pity": 80, "ssr_rate": 1.5}	2026-02-21 13:09:23.389431-05
\.


--
-- Data for Name: titles; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.titles (id, name, description, quality, color, condition_type, condition_value, attack_bonus, defense_bonus, health_bonus, created_at) FROM stdin;
6	万兽克星	击杀100只怪物	rare	#2196f3	kills	100	0.05	0	0	2026-02-18 07:28:51.503908
7	秘境探索者	通关秘境50层	epic	#9c27b0	dungeon_floor	50	0.03	0.03	0.05	2026-02-18 07:28:51.503908
8	富甲一方	拥有100万灵石	legendary	#ff9800	spirit_stones	1000000	0	0	0.1	2026-02-18 07:28:51.503908
9	社交达人	拥有30个好友	rare	#2196f3	friends	30	0	0	0.03	2026-02-18 07:28:51.503908
10	宗门之光	宗门贡献达到10000	epic	#9c27b0	contribution	10000	0.05	0.05	0.05	2026-02-18 07:28:51.503908
11	世界守护者	参与击杀世界Boss	legendary	#ff9800	boss_kill	1	0.08	0.08	0.08	2026-02-18 07:28:51.503908
1	初燃焰火	踏上修仙之路	common	#888888	level	1	0	0	0	2026-02-18 07:28:51.503908
2	铸炉有成	成功筑基	common	#4caf50	level	10	0.01	0.01	0.01	2026-02-18 07:28:51.503908
3	凝焰大成	凝结金丹	rare	#2196f3	level	30	0.03	0.03	0.03	2026-02-18 07:28:51.503908
4	焰婴出窍	元婴出窍，神通初显	epic	#9c27b0	level	50	0.05	0.05	0.05	2026-02-18 07:28:51.503908
5	渡焰真仙	渡过天劫，位列仙班	legendary	#ff9800	level	80	0.08	0.08	0.08	2026-02-18 07:28:51.503908
12	至尊焰帝	达到最高境界	mythic	#f44336	level	100	0.15	0.15	0.15	2026-02-18 07:28:51.503908
\.


--
-- Data for Name: world_bosses; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.world_bosses (id, name, level, max_hp, current_hp, attack, defense, description, rewards_config, status, spawn_time, death_time, created_at) FROM stdin;
1	远古妖龙	100	1000000	0	5000	2000	沉睡万年的远古妖龙苏醒了，它的力量足以毁灭整个焰修界！全体焰修者联手讨伐！	{"top1": 50000, "top2": 30000, "top3": 20000, "top10": 10000, "top50": 5000, "participate": 1000}	dead	2026-02-18 06:36:08.164738-05	2026-02-21 23:10:15.089801-05	2026-02-18 06:36:08.164738-05
\.


--
-- Name: admin_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.admin_logs_id_seq', 9, true);


--
-- Name: announcements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.announcements_id_seq', 15, true);


--
-- Name: ascension_perks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.ascension_perks_id_seq', 7, true);


--
-- Name: ascension_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.ascension_records_id_seq', 3, true);


--
-- Name: auction_bids_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.auction_bids_id_seq', 4, true);


--
-- Name: auction_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.auction_history_id_seq', 4, true);


--
-- Name: auction_listings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.auction_listings_id_seq', 11, true);


--
-- Name: battle_trace_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.battle_trace_log_id_seq', 1, false);


--
-- Name: boss_damage_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.boss_damage_log_id_seq', 39, true);


--
-- Name: boss_rewards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.boss_rewards_id_seq', 1, false);


--
-- Name: bug_reports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.bug_reports_id_seq', 16, true);


--
-- Name: daily_dungeon_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.daily_dungeon_entries_id_seq', 31, true);


--
-- Name: daily_dungeons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.daily_dungeons_id_seq', 4, true);


--
-- Name: equip_slots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.equip_slots_id_seq', 29, true);


--
-- Name: equipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.equipment_id_seq', 1, true);


--
-- Name: event_claims_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.event_claims_id_seq', 3, true);


--
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.events_id_seq', 6, true);


--
-- Name: friend_gifts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.friend_gifts_id_seq', 1, true);


--
-- Name: friendships_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.friendships_id_seq', 4, true);


--
-- Name: inventory_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.inventory_items_id_seq', 25, true);


--
-- Name: leaderboard_cache_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.leaderboard_cache_id_seq', 1784, true);


--
-- Name: login_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.login_logs_id_seq', 28, true);


--
-- Name: monthly_cards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.monthly_cards_id_seq', 1, false);


--
-- Name: mounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.mounts_id_seq', 5, true);


--
-- Name: pets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.pets_id_seq', 1, false);


--
-- Name: pk_rankings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.pk_rankings_id_seq', 1, true);


--
-- Name: pk_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pk_records_id_seq', 9, true);


--
-- Name: player_mail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.player_mail_id_seq', 31, true);


--
-- Name: player_mounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.player_mounts_id_seq', 4, true);


--
-- Name: player_titles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.player_titles_id_seq', 13, true);


--
-- Name: players_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.players_id_seq', 16, true);


--
-- Name: private_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.private_messages_id_seq', 4, true);


--
-- Name: recharge_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recharge_log_id_seq', 2, true);


--
-- Name: sect_members_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.sect_members_id_seq', 6, true);


--
-- Name: sect_tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.sect_tasks_id_seq', 7, true);


--
-- Name: sect_war_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.sect_war_participants_id_seq', 18, true);


--
-- Name: sect_war_rankings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.sect_war_rankings_id_seq', 4, true);


--
-- Name: sect_war_rewards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.sect_war_rewards_id_seq', 18, true);


--
-- Name: sect_wars_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.sect_wars_id_seq', 5, true);


--
-- Name: sects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.sects_id_seq', 2, true);


--
-- Name: titles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.titles_id_seq', 12, true);


--
-- Name: world_bosses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.world_bosses_id_seq', 1, true);


--
-- Name: admin_logs admin_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.admin_logs
    ADD CONSTRAINT admin_logs_pkey PRIMARY KEY (id);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: ascension_perks ascension_perks_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.ascension_perks
    ADD CONSTRAINT ascension_perks_pkey PRIMARY KEY (id);


--
-- Name: ascension_records ascension_records_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.ascension_records
    ADD CONSTRAINT ascension_records_pkey PRIMARY KEY (id);


--
-- Name: auction_bids auction_bids_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.auction_bids
    ADD CONSTRAINT auction_bids_pkey PRIMARY KEY (id);


--
-- Name: auction_history auction_history_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.auction_history
    ADD CONSTRAINT auction_history_pkey PRIMARY KEY (id);


--
-- Name: auction_listings auction_listings_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.auction_listings
    ADD CONSTRAINT auction_listings_pkey PRIMARY KEY (id);


--
-- Name: battle_trace_log battle_trace_log_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.battle_trace_log
    ADD CONSTRAINT battle_trace_log_pkey PRIMARY KEY (id);


--
-- Name: boss_damage_log boss_damage_log_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.boss_damage_log
    ADD CONSTRAINT boss_damage_log_pkey PRIMARY KEY (id);


--
-- Name: boss_rewards boss_rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.boss_rewards
    ADD CONSTRAINT boss_rewards_pkey PRIMARY KEY (id);


--
-- Name: bug_reports bug_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.bug_reports
    ADD CONSTRAINT bug_reports_pkey PRIMARY KEY (id);


--
-- Name: daily_dungeon_entries daily_dungeon_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.daily_dungeon_entries
    ADD CONSTRAINT daily_dungeon_entries_pkey PRIMARY KEY (id);


--
-- Name: daily_dungeons daily_dungeons_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.daily_dungeons
    ADD CONSTRAINT daily_dungeons_pkey PRIMARY KEY (id);


--
-- Name: equip_slots equip_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.equip_slots
    ADD CONSTRAINT equip_slots_pkey PRIMARY KEY (id);


--
-- Name: equip_slots equip_slots_player_id_slot_key; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.equip_slots
    ADD CONSTRAINT equip_slots_player_id_slot_key UNIQUE (player_id, slot);


--
-- Name: equipment equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_pkey PRIMARY KEY (id);


--
-- Name: event_claims event_claims_event_id_wallet_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_claims
    ADD CONSTRAINT event_claims_event_id_wallet_key UNIQUE (event_id, wallet);


--
-- Name: event_claims event_claims_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_claims
    ADD CONSTRAINT event_claims_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: friend_gifts friend_gifts_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.friend_gifts
    ADD CONSTRAINT friend_gifts_pkey PRIMARY KEY (id);


--
-- Name: friendships friendships_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT friendships_pkey PRIMARY KEY (id);


--
-- Name: idempotency_cache idempotency_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.idempotency_cache
    ADD CONSTRAINT idempotency_cache_pkey PRIMARY KEY (key);


--
-- Name: inventory_items inventory_items_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.inventory_items
    ADD CONSTRAINT inventory_items_pkey PRIMARY KEY (id);


--
-- Name: leaderboard_cache leaderboard_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leaderboard_cache
    ADD CONSTRAINT leaderboard_cache_pkey PRIMARY KEY (id);


--
-- Name: login_logs login_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.login_logs
    ADD CONSTRAINT login_logs_pkey PRIMARY KEY (id);


--
-- Name: monthly_cards monthly_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monthly_cards
    ADD CONSTRAINT monthly_cards_pkey PRIMARY KEY (id);


--
-- Name: mounts mounts_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.mounts
    ADD CONSTRAINT mounts_pkey PRIMARY KEY (id);


--
-- Name: pets pets_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.pets
    ADD CONSTRAINT pets_pkey PRIMARY KEY (id);


--
-- Name: pk_rankings pk_rankings_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.pk_rankings
    ADD CONSTRAINT pk_rankings_pkey PRIMARY KEY (id);


--
-- Name: pk_rankings pk_rankings_wallet_key; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.pk_rankings
    ADD CONSTRAINT pk_rankings_wallet_key UNIQUE (wallet);


--
-- Name: pk_records pk_records_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pk_records
    ADD CONSTRAINT pk_records_pkey PRIMARY KEY (id);


--
-- Name: player_mail player_mail_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.player_mail
    ADD CONSTRAINT player_mail_pkey PRIMARY KEY (id);


--
-- Name: player_mounts player_mounts_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.player_mounts
    ADD CONSTRAINT player_mounts_pkey PRIMARY KEY (id);


--
-- Name: player_stats_snapshot player_stats_snapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.player_stats_snapshot
    ADD CONSTRAINT player_stats_snapshot_pkey PRIMARY KEY (player_id);


--
-- Name: player_titles player_titles_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.player_titles
    ADD CONSTRAINT player_titles_pkey PRIMARY KEY (id);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: players players_wallet_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_wallet_key UNIQUE (wallet);


--
-- Name: private_messages private_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.private_messages
    ADD CONSTRAINT private_messages_pkey PRIMARY KEY (id);


--
-- Name: recharge_log recharge_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recharge_log
    ADD CONSTRAINT recharge_log_pkey PRIMARY KEY (id);


--
-- Name: recharge_log recharge_log_tx_hash_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recharge_log
    ADD CONSTRAINT recharge_log_tx_hash_key UNIQUE (tx_hash);


--
-- Name: sect_members sect_members_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_members
    ADD CONSTRAINT sect_members_pkey PRIMARY KEY (id);


--
-- Name: sect_members sect_members_wallet_key; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_members
    ADD CONSTRAINT sect_members_wallet_key UNIQUE (wallet);


--
-- Name: sect_tasks sect_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_tasks
    ADD CONSTRAINT sect_tasks_pkey PRIMARY KEY (id);


--
-- Name: sect_war_participants sect_war_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_war_participants
    ADD CONSTRAINT sect_war_participants_pkey PRIMARY KEY (id);


--
-- Name: sect_war_rankings sect_war_rankings_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_war_rankings
    ADD CONSTRAINT sect_war_rankings_pkey PRIMARY KEY (id);


--
-- Name: sect_war_rewards sect_war_rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_war_rewards
    ADD CONSTRAINT sect_war_rewards_pkey PRIMARY KEY (id);


--
-- Name: sect_wars sect_wars_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_wars
    ADD CONSTRAINT sect_wars_pkey PRIMARY KEY (id);


--
-- Name: sects sects_name_key; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sects
    ADD CONSTRAINT sects_name_key UNIQUE (name);


--
-- Name: sects sects_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sects
    ADD CONSTRAINT sects_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (key);


--
-- Name: titles titles_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.titles
    ADD CONSTRAINT titles_pkey PRIMARY KEY (id);


--
-- Name: world_bosses world_bosses_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.world_bosses
    ADD CONSTRAINT world_bosses_pkey PRIMARY KEY (id);


--
-- Name: idx_auction_active; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_auction_active ON public.auction_listings USING btree (status, expires_at) WHERE ((status)::text = 'active'::text);


--
-- Name: idx_auction_bids_bidder; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_auction_bids_bidder ON public.auction_bids USING btree (bidder_wallet);


--
-- Name: idx_auction_bids_listing; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_auction_bids_listing ON public.auction_bids USING btree (listing_id);


--
-- Name: idx_auction_listings_expires; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_auction_listings_expires ON public.auction_listings USING btree (expires_at);


--
-- Name: idx_auction_listings_seller; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_auction_listings_seller ON public.auction_listings USING btree (seller_wallet);


--
-- Name: idx_auction_listings_status; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_auction_listings_status ON public.auction_listings USING btree (status);


--
-- Name: idx_boss_damage_wallet; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE UNIQUE INDEX idx_boss_damage_wallet ON public.boss_damage_log USING btree (boss_id, wallet);


--
-- Name: idx_boss_rewards_wallet; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_boss_rewards_wallet ON public.boss_rewards USING btree (wallet);


--
-- Name: idx_dde_dungeon_date; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_dde_dungeon_date ON public.daily_dungeon_entries USING btree (dungeon_id, entry_date);


--
-- Name: idx_dde_wallet_date; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_dde_wallet_date ON public.daily_dungeon_entries USING btree (wallet, entry_date);


--
-- Name: idx_equip_player; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_equip_player ON public.equip_slots USING btree (player_id);


--
-- Name: idx_equipment_owner; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_equipment_owner ON public.equipment USING btree (owner_id);


--
-- Name: idx_friend_gifts_to; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_friend_gifts_to ON public.friend_gifts USING btree (to_wallet);


--
-- Name: idx_friendships_accepted; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_friendships_accepted ON public.friendships USING btree (from_wallet, to_wallet) WHERE ((status)::text = 'accepted'::text);


--
-- Name: idx_friendships_from; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_friendships_from ON public.friendships USING btree (from_wallet);


--
-- Name: idx_friendships_status; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_friendships_status ON public.friendships USING btree (status);


--
-- Name: idx_friendships_to; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_friendships_to ON public.friendships USING btree (to_wallet);


--
-- Name: idx_idem_created; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_idem_created ON public.idempotency_cache USING btree (created_at);


--
-- Name: idx_inv_original; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_inv_original ON public.inventory_items USING btree (original_id);


--
-- Name: idx_inv_player; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_inv_player ON public.inventory_items USING btree (player_id);


--
-- Name: idx_login_logs_created; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_login_logs_created ON public.login_logs USING btree (created_at);


--
-- Name: idx_login_logs_wallet; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_login_logs_wallet ON public.login_logs USING btree (wallet);


--
-- Name: idx_mail_expires; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_mail_expires ON public.player_mail USING btree (expires_at) WHERE (expires_at IS NOT NULL);


--
-- Name: idx_mail_wallet; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_mail_wallet ON public.player_mail USING btree (to_wallet, is_read);


--
-- Name: idx_mc_wallet; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mc_wallet ON public.monthly_cards USING btree (wallet);


--
-- Name: idx_pets_owner; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_pets_owner ON public.pets USING btree (owner_id);


--
-- Name: idx_pk_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pk_created ON public.pk_records USING btree (created_at DESC);


--
-- Name: idx_pk_rankings_score; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_pk_rankings_score ON public.pk_rankings USING btree (rank_score DESC);


--
-- Name: idx_pk_rankings_season; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_pk_rankings_season ON public.pk_rankings USING btree (season);


--
-- Name: idx_pk_wallet; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pk_wallet ON public.pk_records USING btree (winner_wallet);


--
-- Name: idx_pk_wallet_a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pk_wallet_a ON public.pk_records USING btree (wallet_a);


--
-- Name: idx_pk_wallet_b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pk_wallet_b ON public.pk_records USING btree (wallet_b);


--
-- Name: idx_players_combat; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_players_combat ON public.players USING btree (combat_power DESC);


--
-- Name: idx_players_combat_power; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_players_combat_power ON public.players USING btree (combat_power DESC);


--
-- Name: idx_players_level; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_players_level ON public.players USING btree (level DESC);


--
-- Name: idx_players_total_recharge; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_players_total_recharge ON public.players USING btree (total_recharge DESC);


--
-- Name: idx_players_wallet; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_players_wallet ON public.players USING btree (wallet);


--
-- Name: idx_pm_conversation; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_pm_conversation ON public.private_messages USING btree (from_wallet, to_wallet, created_at DESC);


--
-- Name: idx_pm_from; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_pm_from ON public.private_messages USING btree (from_wallet);


--
-- Name: idx_pm_read; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_pm_read ON public.private_messages USING btree (to_wallet, is_read);


--
-- Name: idx_pm_to; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_pm_to ON public.private_messages USING btree (to_wallet);


--
-- Name: idx_pm_unread; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_pm_unread ON public.private_messages USING btree (to_wallet, is_read) WHERE (is_read = false);


--
-- Name: idx_recharge_tx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recharge_tx ON public.recharge_log USING btree (tx_hash);


--
-- Name: idx_recharge_wallet; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recharge_wallet ON public.recharge_log USING btree (wallet);


--
-- Name: idx_sect_members_sect; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_sect_members_sect ON public.sect_members USING btree (sect_id);


--
-- Name: idx_sect_members_wallet; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_sect_members_wallet ON public.sect_members USING btree (wallet);


--
-- Name: idx_sect_tasks_sect; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_sect_tasks_sect ON public.sect_tasks USING btree (sect_id);


--
-- Name: idx_sect_wars_challenger; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_sect_wars_challenger ON public.sect_wars USING btree (challenger_sect_id);


--
-- Name: idx_sect_wars_defender; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_sect_wars_defender ON public.sect_wars USING btree (defender_sect_id);


--
-- Name: idx_sect_wars_status; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_sect_wars_status ON public.sect_wars USING btree (status);


--
-- Name: idx_snapshot_version; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_snapshot_version ON public.player_stats_snapshot USING btree (player_id, state_version);


--
-- Name: idx_swp_war; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_swp_war ON public.sect_war_participants USING btree (war_id);


--
-- Name: idx_swr_wallet; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_swr_wallet ON public.sect_war_rewards USING btree (wallet);


--
-- Name: idx_swrank_points; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_swrank_points ON public.sect_war_rankings USING btree (points DESC);


--
-- Name: leaderboard_cache_type_uniq; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX leaderboard_cache_type_uniq ON public.leaderboard_cache USING btree (type);


--
-- Name: auction_bids auction_bids_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.auction_bids
    ADD CONSTRAINT auction_bids_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.auction_listings(id);


--
-- Name: boss_damage_log boss_damage_log_boss_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.boss_damage_log
    ADD CONSTRAINT boss_damage_log_boss_id_fkey FOREIGN KEY (boss_id) REFERENCES public.world_bosses(id);


--
-- Name: boss_rewards boss_rewards_boss_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.boss_rewards
    ADD CONSTRAINT boss_rewards_boss_id_fkey FOREIGN KEY (boss_id) REFERENCES public.world_bosses(id);


--
-- Name: daily_dungeon_entries daily_dungeon_entries_dungeon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.daily_dungeon_entries
    ADD CONSTRAINT daily_dungeon_entries_dungeon_id_fkey FOREIGN KEY (dungeon_id) REFERENCES public.daily_dungeons(id);


--
-- Name: equip_slots equip_slots_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.equip_slots
    ADD CONSTRAINT equip_slots_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: equip_slots equip_slots_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.equip_slots
    ADD CONSTRAINT equip_slots_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: event_claims event_claims_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_claims
    ADD CONSTRAINT event_claims_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id);


--
-- Name: inventory_items inventory_items_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.inventory_items
    ADD CONSTRAINT inventory_items_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: player_mounts player_mounts_mount_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.player_mounts
    ADD CONSTRAINT player_mounts_mount_id_fkey FOREIGN KEY (mount_id) REFERENCES public.mounts(id);


--
-- Name: player_stats_snapshot player_stats_snapshot_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.player_stats_snapshot
    ADD CONSTRAINT player_stats_snapshot_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: player_titles player_titles_title_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.player_titles
    ADD CONSTRAINT player_titles_title_id_fkey FOREIGN KEY (title_id) REFERENCES public.titles(id);


--
-- Name: sect_members sect_members_sect_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_members
    ADD CONSTRAINT sect_members_sect_id_fkey FOREIGN KEY (sect_id) REFERENCES public.sects(id) ON DELETE CASCADE;


--
-- Name: sect_tasks sect_tasks_sect_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_tasks
    ADD CONSTRAINT sect_tasks_sect_id_fkey FOREIGN KEY (sect_id) REFERENCES public.sects(id) ON DELETE CASCADE;


--
-- Name: sect_war_participants sect_war_participants_sect_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_war_participants
    ADD CONSTRAINT sect_war_participants_sect_id_fkey FOREIGN KEY (sect_id) REFERENCES public.sects(id);


--
-- Name: sect_war_participants sect_war_participants_war_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_war_participants
    ADD CONSTRAINT sect_war_participants_war_id_fkey FOREIGN KEY (war_id) REFERENCES public.sect_wars(id);


--
-- Name: sect_war_rankings sect_war_rankings_sect_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_war_rankings
    ADD CONSTRAINT sect_war_rankings_sect_id_fkey FOREIGN KEY (sect_id) REFERENCES public.sects(id);


--
-- Name: sect_war_rewards sect_war_rewards_sect_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_war_rewards
    ADD CONSTRAINT sect_war_rewards_sect_id_fkey FOREIGN KEY (sect_id) REFERENCES public.sects(id);


--
-- Name: sect_war_rewards sect_war_rewards_war_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_war_rewards
    ADD CONSTRAINT sect_war_rewards_war_id_fkey FOREIGN KEY (war_id) REFERENCES public.sect_wars(id);


--
-- Name: sect_wars sect_wars_challenger_sect_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_wars
    ADD CONSTRAINT sect_wars_challenger_sect_id_fkey FOREIGN KEY (challenger_sect_id) REFERENCES public.sects(id);


--
-- Name: sect_wars sect_wars_defender_sect_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_wars
    ADD CONSTRAINT sect_wars_defender_sect_id_fkey FOREIGN KEY (defender_sect_id) REFERENCES public.sects(id);


--
-- Name: sect_wars sect_wars_winner_sect_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.sect_wars
    ADD CONSTRAINT sect_wars_winner_sect_id_fkey FOREIGN KEY (winner_sect_id) REFERENCES public.sects(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO roon_user;


--
-- Name: TABLE announcements; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.announcements TO roon_user;


--
-- Name: SEQUENCE announcements_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.announcements_id_seq TO roon_user;


--
-- Name: TABLE event_claims; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.event_claims TO roon_user;


--
-- Name: SEQUENCE event_claims_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.event_claims_id_seq TO roon_user;


--
-- Name: TABLE events; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.events TO roon_user;


--
-- Name: SEQUENCE events_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.events_id_seq TO roon_user;


--
-- Name: TABLE leaderboard_cache; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.leaderboard_cache TO roon_user;


--
-- Name: SEQUENCE leaderboard_cache_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.leaderboard_cache_id_seq TO roon_user;


--
-- Name: TABLE monthly_cards; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.monthly_cards TO roon_user;


--
-- Name: SEQUENCE monthly_cards_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.monthly_cards_id_seq TO roon_user;


--
-- Name: TABLE pk_records; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.pk_records TO roon_user;


--
-- Name: SEQUENCE pk_records_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.pk_records_id_seq TO roon_user;


--
-- Name: TABLE players; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.players TO roon_user;


--
-- Name: SEQUENCE players_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.players_id_seq TO roon_user;


--
-- Name: TABLE recharge_log; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.recharge_log TO roon_user;


--
-- Name: SEQUENCE recharge_log_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.recharge_log_id_seq TO roon_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO roon_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO roon_user;


--
-- PostgreSQL database dump complete
--

\unrestrict fjAfs3Xbg1xcKtD5Fx5MpBkyd6WketRzPPeYYWBiN3To1njBhVaaOqYWqhI3FoL

