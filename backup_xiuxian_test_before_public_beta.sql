--
-- PostgreSQL database dump
--

\restrict hiwSfvLdYGnLNSjdFtrjyOx8CX8DzLnD6FyrljPtGcrEvVlaurPCzAjbezpfiCa

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
-- Name: announcements; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.announcements (
    id integer NOT NULL,
    content text NOT NULL,
    type character varying(20) DEFAULT 'info'::character varying,
    active boolean DEFAULT true,
    sort_order integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.announcements OWNER TO roon_user;

--
-- Name: announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.announcements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.announcements_id_seq OWNER TO roon_user;

--
-- Name: announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.announcements_id_seq OWNED BY public.announcements.id;


--
-- Name: arena_battles; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.arena_battles (
    id integer NOT NULL,
    attacker_wallet character varying(100) NOT NULL,
    defender_wallet character varying(100) NOT NULL,
    winner character varying(100),
    attacker_score_change integer DEFAULT 0,
    defender_score_change integer DEFAULT 0,
    reward_stones integer DEFAULT 0,
    is_revenge boolean DEFAULT false,
    rounds_data jsonb,
    attacker_name character varying(100),
    defender_name character varying(100),
    attacker_power integer DEFAULT 0,
    defender_power integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.arena_battles OWNER TO roon_user;

--
-- Name: arena_battles_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.arena_battles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.arena_battles_id_seq OWNER TO roon_user;

--
-- Name: arena_battles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.arena_battles_id_seq OWNED BY public.arena_battles.id;


--
-- Name: arena_daily; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.arena_daily (
    id integer NOT NULL,
    wallet character varying(100) NOT NULL,
    date date DEFAULT CURRENT_DATE NOT NULL,
    challenges_used integer DEFAULT 0,
    wins integer DEFAULT 0,
    first_challenge_reward boolean DEFAULT false,
    five_win_reward boolean DEFAULT false
);


ALTER TABLE public.arena_daily OWNER TO roon_user;

--
-- Name: arena_daily_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.arena_daily_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.arena_daily_id_seq OWNER TO roon_user;

--
-- Name: arena_daily_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.arena_daily_id_seq OWNED BY public.arena_daily.id;


--
-- Name: arena_notifications; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.arena_notifications (
    id integer NOT NULL,
    wallet character varying(100) NOT NULL,
    attacker_wallet character varying(100) NOT NULL,
    attacker_name character varying(100),
    score_change integer DEFAULT 0,
    battle_id integer,
    read boolean DEFAULT false,
    revenged boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.arena_notifications OWNER TO roon_user;

--
-- Name: arena_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.arena_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.arena_notifications_id_seq OWNER TO roon_user;

--
-- Name: arena_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.arena_notifications_id_seq OWNED BY public.arena_notifications.id;


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
-- Name: event_claims; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.event_claims (
    id integer NOT NULL,
    event_id integer,
    wallet character varying(42) NOT NULL,
    claimed_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.event_claims OWNER TO roon_user;

--
-- Name: event_claims_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.event_claims_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.event_claims_id_seq OWNER TO roon_user;

--
-- Name: event_claims_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.event_claims_id_seq OWNED BY public.event_claims.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: roon_user
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


ALTER TABLE public.events OWNER TO roon_user;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.events_id_seq OWNER TO roon_user;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
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
-- Name: leaderboard_cache; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.leaderboard_cache (
    id integer NOT NULL,
    type character varying(20) NOT NULL,
    data jsonb DEFAULT '[]'::jsonb,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.leaderboard_cache OWNER TO roon_user;

--
-- Name: leaderboard_cache_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.leaderboard_cache_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.leaderboard_cache_id_seq OWNER TO roon_user;

--
-- Name: leaderboard_cache_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
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
-- Name: minigame_scores; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.minigame_scores (
    id integer NOT NULL,
    wallet character varying(100) NOT NULL,
    month character varying(7) NOT NULL,
    total_score bigint DEFAULT 0
);


ALTER TABLE public.minigame_scores OWNER TO roon_user;

--
-- Name: minigame_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.minigame_scores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.minigame_scores_id_seq OWNER TO roon_user;

--
-- Name: minigame_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.minigame_scores_id_seq OWNED BY public.minigame_scores.id;


--
-- Name: monthly_cards; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.monthly_cards (
    id integer NOT NULL,
    wallet character varying(42) NOT NULL,
    purchased_at timestamp without time zone DEFAULT now(),
    expires_at timestamp without time zone NOT NULL,
    last_claim_date date,
    days_claimed integer DEFAULT 0
);


ALTER TABLE public.monthly_cards OWNER TO roon_user;

--
-- Name: monthly_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.monthly_cards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.monthly_cards_id_seq OWNER TO roon_user;

--
-- Name: monthly_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.monthly_cards_id_seq OWNED BY public.monthly_cards.id;


--
-- Name: monthly_rankings; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.monthly_rankings (
    id integer NOT NULL,
    month character varying(7) NOT NULL,
    rank_type character varying(20) NOT NULL,
    rank_position integer NOT NULL,
    wallet character varying(100) NOT NULL,
    player_name character varying(100),
    score bigint DEFAULT 0,
    reward_roon numeric(18,6) DEFAULT 0,
    reward_stones integer DEFAULT 0,
    claimed boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.monthly_rankings OWNER TO roon_user;

--
-- Name: monthly_rankings_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.monthly_rankings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.monthly_rankings_id_seq OWNER TO roon_user;

--
-- Name: monthly_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.monthly_rankings_id_seq OWNED BY public.monthly_rankings.id;


--
-- Name: monthly_revenue; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.monthly_revenue (
    id integer NOT NULL,
    month character varying(7) NOT NULL,
    total_roon numeric(18,6) DEFAULT 0,
    reward_pool numeric(18,6) DEFAULT 0,
    snapshot_done boolean DEFAULT false,
    distributed boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.monthly_revenue OWNER TO roon_user;

--
-- Name: monthly_revenue_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.monthly_revenue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.monthly_revenue_id_seq OWNER TO roon_user;

--
-- Name: monthly_revenue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.monthly_revenue_id_seq OWNED BY public.monthly_revenue.id;


--
-- Name: monthly_spending; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.monthly_spending (
    id integer NOT NULL,
    wallet character varying(100) NOT NULL,
    month character varying(7) NOT NULL,
    total_spent bigint DEFAULT 0
);


ALTER TABLE public.monthly_spending OWNER TO roon_user;

--
-- Name: monthly_spending_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.monthly_spending_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.monthly_spending_id_seq OWNER TO roon_user;

--
-- Name: monthly_spending_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.monthly_spending_id_seq OWNED BY public.monthly_spending.id;


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
-- Name: pk_rankings; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.pk_rankings OWNER TO postgres;

--
-- Name: pk_rankings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pk_rankings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pk_rankings_id_seq OWNER TO postgres;

--
-- Name: pk_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pk_rankings_id_seq OWNED BY public.pk_rankings.id;


--
-- Name: pk_records; Type: TABLE; Schema: public; Owner: roon_user
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


ALTER TABLE public.pk_records OWNER TO roon_user;

--
-- Name: pk_records_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.pk_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pk_records_id_seq OWNER TO roon_user;

--
-- Name: pk_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.pk_records_id_seq OWNED BY public.pk_records.id;


--
-- Name: pk_season_history; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.pk_season_history (
    id integer NOT NULL,
    season_num integer NOT NULL,
    wallet character varying(100) NOT NULL,
    rank_score integer DEFAULT 0,
    rank_tier character varying(20) DEFAULT 'bronze'::character varying,
    wins integer DEFAULT 0,
    losses integer DEFAULT 0,
    draws integer DEFAULT 0,
    max_win_streak integer DEFAULT 0,
    final_rank integer DEFAULT 0,
    reward_stones integer DEFAULT 0,
    reward_title character varying(50) DEFAULT ''::character varying,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.pk_season_history OWNER TO roon_user;

--
-- Name: pk_season_history_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.pk_season_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pk_season_history_id_seq OWNER TO roon_user;

--
-- Name: pk_season_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.pk_season_history_id_seq OWNED BY public.pk_season_history.id;


--
-- Name: pk_seasons; Type: TABLE; Schema: public; Owner: roon_user
--

CREATE TABLE public.pk_seasons (
    id integer NOT NULL,
    season_num integer NOT NULL,
    month character varying(7) NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    status character varying(20) DEFAULT 'active'::character varying,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.pk_seasons OWNER TO roon_user;

--
-- Name: pk_seasons_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.pk_seasons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pk_seasons_id_seq OWNER TO roon_user;

--
-- Name: pk_seasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
--

ALTER SEQUENCE public.pk_seasons_id_seq OWNED BY public.pk_seasons.id;


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
-- Name: players; Type: TABLE; Schema: public; Owner: roon_user
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
    state_version bigint DEFAULT 0
);


ALTER TABLE public.players OWNER TO roon_user;

--
-- Name: players_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.players_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.players_id_seq OWNER TO roon_user;

--
-- Name: players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
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
-- Name: recharge_log; Type: TABLE; Schema: public; Owner: roon_user
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


ALTER TABLE public.recharge_log OWNER TO roon_user;

--
-- Name: recharge_log_id_seq; Type: SEQUENCE; Schema: public; Owner: roon_user
--

CREATE SEQUENCE public.recharge_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.recharge_log_id_seq OWNER TO roon_user;

--
-- Name: recharge_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roon_user
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
-- Name: announcements id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.announcements ALTER COLUMN id SET DEFAULT nextval('public.announcements_id_seq'::regclass);


--
-- Name: arena_battles id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.arena_battles ALTER COLUMN id SET DEFAULT nextval('public.arena_battles_id_seq'::regclass);


--
-- Name: arena_daily id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.arena_daily ALTER COLUMN id SET DEFAULT nextval('public.arena_daily_id_seq'::regclass);


--
-- Name: arena_notifications id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.arena_notifications ALTER COLUMN id SET DEFAULT nextval('public.arena_notifications_id_seq'::regclass);


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
-- Name: event_claims id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.event_claims ALTER COLUMN id SET DEFAULT nextval('public.event_claims_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: roon_user
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
-- Name: leaderboard_cache id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.leaderboard_cache ALTER COLUMN id SET DEFAULT nextval('public.leaderboard_cache_id_seq'::regclass);


--
-- Name: login_logs id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.login_logs ALTER COLUMN id SET DEFAULT nextval('public.login_logs_id_seq'::regclass);


--
-- Name: minigame_scores id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.minigame_scores ALTER COLUMN id SET DEFAULT nextval('public.minigame_scores_id_seq'::regclass);


--
-- Name: monthly_cards id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.monthly_cards ALTER COLUMN id SET DEFAULT nextval('public.monthly_cards_id_seq'::regclass);


--
-- Name: monthly_rankings id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.monthly_rankings ALTER COLUMN id SET DEFAULT nextval('public.monthly_rankings_id_seq'::regclass);


--
-- Name: monthly_revenue id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.monthly_revenue ALTER COLUMN id SET DEFAULT nextval('public.monthly_revenue_id_seq'::regclass);


--
-- Name: monthly_spending id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.monthly_spending ALTER COLUMN id SET DEFAULT nextval('public.monthly_spending_id_seq'::regclass);


--
-- Name: mounts id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.mounts ALTER COLUMN id SET DEFAULT nextval('public.mounts_id_seq'::regclass);


--
-- Name: pets id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.pets ALTER COLUMN id SET DEFAULT nextval('public.pets_id_seq'::regclass);


--
-- Name: pk_rankings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pk_rankings ALTER COLUMN id SET DEFAULT nextval('public.pk_rankings_id_seq'::regclass);


--
-- Name: pk_records id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.pk_records ALTER COLUMN id SET DEFAULT nextval('public.pk_records_id_seq'::regclass);


--
-- Name: pk_season_history id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.pk_season_history ALTER COLUMN id SET DEFAULT nextval('public.pk_season_history_id_seq'::regclass);


--
-- Name: pk_seasons id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.pk_seasons ALTER COLUMN id SET DEFAULT nextval('public.pk_seasons_id_seq'::regclass);


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
-- Name: players id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.players ALTER COLUMN id SET DEFAULT nextval('public.players_id_seq'::regclass);


--
-- Name: private_messages id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.private_messages ALTER COLUMN id SET DEFAULT nextval('public.private_messages_id_seq'::regclass);


--
-- Name: recharge_log id; Type: DEFAULT; Schema: public; Owner: roon_user
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
1	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	delete_announcement	3	{}	2026-02-18 11:02:31.157106-05
2	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	delete_announcement	2	{}	2026-02-18 11:02:32.980928-05
3	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	delete_announcement	1	{}	2026-02-18 11:02:35.901093-05
4	0x82e402b05f3e936b63a874788c73e1552657c4f7	update_shop_config	shop_config	{"reinforce_stone": 1000, "reinforce_stone_10": 9000}	2026-02-21 13:09:22.330625-05
5	0x82e402b05f3e936b63a874788c73e1552657c4f7	update_gacha_config	gacha_config	{"r_rate": 88.5, "sr_rate": 10, "ssr_pity": 80, "ssr_rate": 1.5}	2026-02-21 13:09:23.391045-05
6	0x82e402b05f3e936b63a874788c73e1552657c4f7	edit_player_level	0x82e402b05f3e936b63a874788c73e1552657c4f7	{"level": 50, "realm": "化焰五重"}	2026-02-21 13:09:24.110502-05
7	0x82e402b05f3e936b63a874788c73e1552657c4f7	edit_player_vip	0x82e402b05f3e936b63a874788c73e1552657c4f7	{"vipLevel": 5}	2026-02-21 13:09:24.469457-05
8	0x82e402b05f3e936b63a874788c73e1552657c4f7	edit_player_gamedata	0x82e402b05f3e936b63a874788c73e1552657c4f7	{"fields": ["testField"]}	2026-02-21 13:09:24.839865-05
9	0x82e402b05f3e936b63a874788c73e1552657c4f7	airdrop	all	{"sent": 13, "petEssence": 0, "spiritStones": 0, "reinforceStones": 0, "refinementStones": 0}	2026-02-21 13:10:23.224182-05
\.


--
-- Data for Name: announcements; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.announcements (id, content, type, active, sort_order, created_at) FROM stdin;
4	🔥 火之文明：焰修传说 正式上线！欢迎各位焰修者！	info	f	1	2026-02-21 04:17:15.126291
5	⚔️ 黑焰入侵已开启，击败远古妖龙可获珍稀坐骑！	event	f	2	2026-02-21 04:17:15.126291
6	💎 首充双倍焰晶活动进行中，充值即享超值回馈！	promo	f	3	2026-02-21 04:17:15.126291
7	🔥 欢迎来到「火之文明」内测！连接钱包即可开始修炼之旅，遇到问题请点右下角🐛反馈	info	t	1	2026-02-23 07:21:17.053856
8	📖 新手攻略：冥想(消耗焰灵→获得焰力)→突破境界→探索获取焰草焰晶→抽卡获得装备焰兽→提升战力	info	t	2	2026-02-23 07:21:17.053856
9	🧘 核心玩法：焰灵自动恢复，点「一键冥想」消耗全部焰灵换焰力，焰力满了就能突破升级！	info	t	3	2026-02-23 07:21:17.053856
10	🗺️ 探索地图：薪火村(1级)→赤霄峰(10级)→涅槃谷(19级)→焰渊(28级)→焰天圣域(37级)，可获焰草、焰晶、丹方残页	info	t	4	2026-02-23 07:21:17.053856
11	🎰 抽卡系统：单抽300焰晶，装备6品质(凡→良→优→极→仙→神)，焰兽5品质，有保底机制	info	t	5	2026-02-23 07:21:17.053856
12	💎 赚焰晶途径：冥想离线收益、探索、签到(每日500-5000)、每日副本、PK胜利、回收多余物品	info	t	6	2026-02-23 07:21:17.053856
13	💳 薪火令(月卡)：10 ROON/30天，每日5000焰晶+冥想加速20%+免费抽卡1次，超值推荐！	promo	t	7	2026-02-23 07:21:17.053856
14	⚔️ 提升战力：穿装备→淬火强化→出战焰兽→服用焰丹buff→挑战PK和世界Boss！	info	t	8	2026-02-23 07:21:17.053856
15	🔥 公测正式开启！火之文明 beta v1.0 全新起航，公测期间新玩家赠送20,000焰晶！修炼、探索、抽卡、PK竞技场、焰盟战、世界Boss等玩法全面开放，欢迎各位焰修者加入！	event	t	0	2026-02-23 07:23:18.10395
\.


--
-- Data for Name: arena_battles; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.arena_battles (id, attacker_wallet, defender_wallet, winner, attacker_score_change, defender_score_change, reward_stones, is_revenge, rounds_data, attacker_name, defender_name, attacker_power, defender_power, created_at) FROM stdin;
26	0x82e402b05f3e936b63a874788c73e1552657c4f7	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	0x82e402b05f3e936b63a874788c73e1552657c4f7	25	-20	300	f	[{"hpA": 31667, "hpB": 0, "round": 1, "actions": [{"damage": 26169, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}]	测试账号 1	无名修士	51392	0	2026-02-24 14:11:52.678464
27	0x82e402b05f3e936b63a874788c73e1552657c4f7	0xbot004	0xbot004	-15	10	0	f	[{"hpA": 31667, "hpB": 124000, "round": 1, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 0, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": true}]}, {"hpA": 31667, "hpB": 123708, "round": 2, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 292, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 123416, "round": 3, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 292, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 123124, "round": 4, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 292, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 123124, "round": 5, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 0, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": true}]}, {"hpA": 31667, "hpB": 122832, "round": 6, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 292, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 122540, "round": 7, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 292, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 122248, "round": 8, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 292, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 121956, "round": 9, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 292, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 121664, "round": 10, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 292, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 121372, "round": 11, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 292, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 121080, "round": 12, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 292, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 120788, "round": 13, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 292, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 120496, "round": 14, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 292, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 120204, "round": 15, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 292, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}]	测试账号 1	焰影·星辰	51392	62000	2026-02-24 14:12:08.149726
28	0x82e402b05f3e936b63a874788c73e1552657c4f7	0xbot001	0xbot001	-15	10	0	f	[{"hpA": 31667, "hpB": 89599, "round": 1, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 401, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 89198, "round": 2, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 401, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 88797, "round": 3, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 401, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 88396, "round": 4, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 401, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 87995, "round": 5, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 401, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 87594, "round": 6, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 401, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 87193, "round": 7, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 401, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 86792, "round": 8, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 401, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 86391, "round": 9, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 401, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 85990, "round": 10, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 401, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 85589, "round": 11, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 401, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 85188, "round": 12, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 401, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 84787, "round": 13, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 401, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 84386, "round": 14, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 401, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 83985, "round": 15, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 401, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}]	测试账号 1	焰影·烈风	51392	45000	2026-02-24 14:12:36.004975
29	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	0x82e402b05f3e936b63a874788c73e1552657c4f7	0x82e402b05f3e936b63a874788c73e1552657c4f7	-15	10	0	t	[{"hpA": 0, "hpB": 31667, "round": 1, "actions": [{"damage": 26169, "isCrit": true, "isCombo": true, "attacker": "B", "isDodged": false}]}]	无名修士	测试账号 1	0	51392	2026-02-24 14:13:36.672806
30	0x82e402b05f3e936b63a874788c73e1552657c4f7	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	0x82e402b05f3e936b63a874788c73e1552657c4f7	35	-20	300	t	[{"hpA": 31667, "hpB": 0, "round": 1, "actions": [{"damage": 26169, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}]	测试账号 1	无名修士	51392	0	2026-02-24 14:14:33.671728
31	0x82e402b05f3e936b63a874788c73e1552657c4f7	0xbot006	0xbot006	-15	10	0	f	[{"hpA": 31667, "hpB": 103653, "round": 1, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 347, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 103306, "round": 2, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 347, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 102959, "round": 3, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 347, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 102612, "round": 4, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 347, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 102265, "round": 5, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 347, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 101918, "round": 6, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 347, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 101571, "round": 7, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 347, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 101224, "round": 8, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 347, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 100877, "round": 9, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 347, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 100530, "round": 10, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 347, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 100530, "round": 11, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 0, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": true}]}, {"hpA": 31667, "hpB": 100183, "round": 12, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 347, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 99836, "round": 13, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 347, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 99489, "round": 14, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 347, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31667, "hpB": 99142, "round": 15, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 347, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}]	测试账号 1	焰影·天罡	51392	52000	2026-02-24 14:19:47.098328
32	0x82e402b05f3e936b63a874788c73e1552657c4f7	0xbot008	0xbot008	-15	10	0	f	[{"hpA": 32433, "hpB": 99862, "round": 1, "actions": [{"damage": 272, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 138, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 32173, "hpB": 99785, "round": 2, "actions": [{"damage": 272, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 77, "isCrit": false, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31924, "hpB": 99647, "round": 3, "actions": [{"damage": 272, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 138, "isCrit": true, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31575, "hpB": 99588, "round": 4, "actions": [{"damage": 358, "isCrit": true, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 59, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 31587, "hpB": 99511, "round": 5, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 77, "isCrit": false, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 31324, "hpB": 99452, "round": 6, "actions": [{"damage": 272, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 59, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 31061, "hpB": 99371, "round": 7, "actions": [{"damage": 272, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 22, "attacker": "A", "isCounter": true}, {"damage": 59, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 30798, "hpB": 99312, "round": 8, "actions": [{"damage": 272, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 59, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 30807, "hpB": 99253, "round": 9, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 59, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 30544, "hpB": 99172, "round": 10, "actions": [{"damage": 272, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 22, "attacker": "A", "isCounter": true}, {"damage": 59, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 30284, "hpB": 99073, "round": 11, "actions": [{"damage": 272, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 22, "attacker": "A", "isCounter": true}, {"damage": 77, "isCrit": false, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 30021, "hpB": 99014, "round": 12, "actions": [{"damage": 272, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 59, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 30033, "hpB": 98937, "round": 13, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 77, "isCrit": false, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 30045, "hpB": 98860, "round": 14, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 77, "isCrit": false, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 30057, "hpB": 98783, "round": 15, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 77, "isCrit": false, "isCombo": true, "attacker": "A", "isDodged": false}]}]	测试账号 1	焰影·朱雀	49604	50000	2026-02-24 20:07:03.318866
33	0x82e402b05f3e936b63a874788c73e1552657c4f7	0xbot005	0xbot005	-15	10	0	f	[{"hpA": 33469, "hpB": 79895, "round": 1, "actions": [{"damage": 211, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 28, "attacker": "A", "isCounter": true}, {"damage": 77, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 33275, "hpB": 79795, "round": 2, "actions": [{"damage": 211, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 100, "isCrit": false, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 33077, "hpB": 79718, "round": 3, "actions": [{"damage": 211, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 77, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 32879, "hpB": 79641, "round": 4, "actions": [{"damage": 211, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 77, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 32692, "hpB": 79503, "round": 5, "actions": [{"damage": 211, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 138, "isCrit": true, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 32498, "hpB": 79375, "round": 6, "actions": [{"damage": 211, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 28, "attacker": "A", "isCounter": true}, {"damage": 100, "isCrit": false, "isCombo": true, "attacker": "A", "isDodged": false}]}, {"hpA": 32300, "hpB": 79298, "round": 7, "actions": [{"damage": 211, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 77, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 32313, "hpB": 79221, "round": 8, "actions": [{"damage": 0, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": true}, {"damage": 77, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 32115, "hpB": 79144, "round": 9, "actions": [{"damage": 211, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 77, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 31928, "hpB": 79006, "round": 10, "actions": [{"damage": 211, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 138, "isCrit": true, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 31741, "hpB": 78868, "round": 11, "actions": [{"damage": 211, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 138, "isCrit": true, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 31543, "hpB": 78791, "round": 12, "actions": [{"damage": 211, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 77, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 31345, "hpB": 78714, "round": 13, "actions": [{"damage": 211, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 77, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 31147, "hpB": 78637, "round": 14, "actions": [{"damage": 211, "isCrit": false, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 77, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}, {"hpA": 30884, "hpB": 78560, "round": 15, "actions": [{"damage": 276, "isCrit": true, "isCombo": false, "attacker": "B", "isDodged": false}, {"damage": 77, "isCrit": false, "isCombo": false, "attacker": "A", "isDodged": false}]}]	测试账号 1	焰影·幽冥	49704	40000	2026-02-24 21:21:03.865133
34	0x82e402b05f3e936b63a874788c73e1552657c4f7	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	0x82e402b05f3e936b63a874788c73e1552657c4f7	25	-20	200	f	[{"hpA": 33667, "hpB": 0, "round": 1, "actions": [{"damage": 8050, "isCrit": true, "isCombo": false, "attacker": "A", "isDodged": false}]}]	测试账号 1	无名修士	52869	0	2026-02-24 21:24:54.81553
\.


--
-- Data for Name: arena_daily; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.arena_daily (id, wallet, date, challenges_used, wins, first_challenge_reward, five_win_reward) FROM stdin;
88	0x82e402b05f3e936b63a874788c73e1552657c4f7	2026-02-24	7	3	t	f
92	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	2026-02-24	0	0	t	f
\.


--
-- Data for Name: arena_notifications; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.arena_notifications (id, wallet, attacker_wallet, attacker_name, score_change, battle_id, read, revenged, created_at) FROM stdin;
16	0xbot004	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	10	27	f	f	2026-02-24 14:12:08.153988
17	0xbot001	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	10	28	f	f	2026-02-24 14:12:36.008134
15	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	-20	26	t	t	2026-02-24 14:11:52.688732
19	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	-20	30	f	f	2026-02-24 14:14:33.674571
18	0x82e402b05f3e936b63a874788c73e1552657c4f7	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	无名修士	10	29	t	t	2026-02-24 14:13:36.676627
20	0xbot006	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	10	31	f	f	2026-02-24 14:19:47.102199
21	0xbot008	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	10	32	f	f	2026-02-24 20:07:03.323944
22	0xbot005	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	10	33	f	f	2026-02-24 21:21:03.867999
23	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	-20	34	f	f	2026-02-24 21:24:54.820541
\.


--
-- Data for Name: ascension_perks; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.ascension_perks (id, ascension_level, name, description, attack_bonus, defense_bonus, health_bonus, speed_bonus, cultivation_speed_bonus, special_perk, created_at) FROM stdin;
1	1	初次涅槃	浴火重生，焰力觉醒。基础属性永久+10%	0.1	0.1	0.1	0.1	0.1	解锁飞升商店	2026-02-18 07:36:02.397441
2	2	二次涅槃	焰心坚固，焰力更进。基础属性永久+25%	0.25	0.25	0.25	0.25	0.2	抽卡保底-10次	2026-02-18 07:36:02.397441
3	3	三次涅槃	天焰感应，万法归一。基础属性永久+50%	0.5	0.5	0.5	0.5	0.35	每日副本+1次	2026-02-18 07:36:02.397441
4	4	四次涅槃	超凡入圣，不灭焰体。基础属性永久+80%	0.8	0.8	0.8	0.8	0.5	秘境起始+10层	2026-02-18 07:36:02.397441
5	5	五次涅槃	大道至简，焰人合一。基础属性永久+120%	1.2	1.2	1.2	1.2	0.75	解锁鲲鹏坐骑	2026-02-18 07:36:02.397441
6	6	六次涅槃	混元永焰，永恒不灭。基础属性永久+170%	1.7	1.7	1.7	1.7	1	全属性翻倍	2026-02-18 07:36:02.397441
7	7	七次涅槃	超越轮回，创世焰力。基础属性永久+230%	2.3	2.3	2.3	2.3	1.5	无敌模式(PVE)	2026-02-18 07:36:02.397441
\.


--
-- Data for Name: ascension_records; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.ascension_records (id, wallet, ascension_count, previous_level, bonuses, ascended_at) FROM stdin;
1	0xadb0ecf47e175089579da5182dd7707328575909	1	101	{"speed": 0.1, "attack": 0.1, "health": 0.1, "defense": 0.1, "cultivationSpeed": 0.1}	2026-02-18 07:46:59.05531
2	0xadb0ecf47e175089579da5182dd7707328575909	1	101	{"speed": 0.1, "attack": 0.1, "health": 0.1, "defense": 0.1, "cultivationSpeed": 0.1}	2026-02-18 07:47:15.628813
3	0xbot0000000000000000000000000000000000a1	1	100	{"speed": 0.1, "attack": 0.1, "health": 0.1, "defense": 0.1, "cultivationSpeed": 0.1}	2026-02-21 02:21:29.241907
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
1	1	0xadb0ecf47e175089579da5182dd7707328575909	0x82e402b05f3e936b63a874788c73e1552657c4f7	天罗手套·天	hands	rare	100	2026-02-19 12:39:20.538464
2	6	0xbot0000000000000000000000000000000000a1	0xbot0000000000000000000000000000000000b2	幽岚肩甲	shoulder	common	5000	2026-02-21 01:51:15.651429
3	7	0xbot0000000000000000000000000000000000a1	0x82e402b05f3e936b63a874788c73e1552657c4f7	幽冥焰杖	weapon	common	5000	2026-02-21 07:28:27.761583
4	11	0x82e402b05f3e936b63a874788c73e1552657c4f7	0xc385d64735689929311621f4e81ca5b4e7830055	星晶护腕·仙	wrist	epic	50000	2026-02-23 06:30:03.686904
5	10	0x82e402b05f3e936b63a874788c73e1552657c4f7	0xc385d64735689929311621f4e81ca5b4e7830055	赤炎焰杖·圣	weapon	legendary	5000	2026-02-23 06:30:06.247679
6	9	0x82e402b05f3e936b63a874788c73e1552657c4f7	0xc385d64735689929311621f4e81ca5b4e7830055	星系腰带·仙	belt	epic	50000	2026-02-23 06:30:08.37568
7	12	0x82e402b05f3e936b63a874788c73e1552657c4f7	0xc385d64735689929311621f4e81ca5b4e7830055	仙灵丹	pill	epic	50000	2026-02-23 06:32:01.663886
\.


--
-- Data for Name: auction_listings; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.auction_listings (id, seller_wallet, seller_name, item_data, item_name, item_type, item_quality, starting_price, buyout_price, current_bid, current_bidder, bid_count, duration_hours, status, expires_at, created_at) FROM stdin;
6	0xbot0000000000000000000000000000000000a1	剑魔·青锋	{"id": 1771656525094.8723, "name": "幽岚肩甲", "slot": "shoulder", "type": "shoulder", "level": 15, "stats": {"health": 131, "defense": 24, "counterRate": 0.19}, "quality": "common", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 15}	幽岚肩甲	shoulder	common	1000	5000	5000	0xbot0000000000000000000000000000000000b2	1	12	sold	2026-02-21 13:51:03.095	2026-02-21 01:51:03.096151
7	0xbot0000000000000000000000000000000000a1	无名修士	{"id": 1771671472237.8748, "name": "幽冥焰杖", "slot": "weapon", "type": "weapon", "level": 1, "stats": {"attack": 12, "critRate": 0.1, "critDamageBoost": 0.19}, "quality": "common", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 1}	幽冥焰杖	weapon	common	100	5000	5000	0x82e402b05f3e936b63a874788c73e1552657c4f7	2	12	sold	2026-02-21 18:01:18.442	2026-02-21 06:01:18.44325
1	0xadb0ecf47e175089579da5182dd7707328575909	无名修士	{"id": 1771357833356.723, "name": "天罗手套·天", "slot": "hands", "type": "hands", "level": 1, "stats": {"attack": 12, "critRate": 0, "comboRate": 0}, "quality": "rare", "equipType": "hands", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 1}	天罗手套·天	hands	rare	100	\N	100	0x82e402b05f3e936b63a874788c73e1552657c4f7	1	24	sold	2026-02-19 07:48:36.85	2026-02-18 07:48:36.851687
2	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名修士	{"id": 1771440497366.911, "name": "星步鞋子·仙", "slot": "feet", "type": "feet", "level": 19, "stats": {"speed": 66, "defense": 36, "dodgeRate": 0}, "quality": "epic", "equipType": "feet", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 19}	星步鞋子·仙	feet	epic	99999	\N	0	\N	0	24	cancelled	2026-02-19 13:50:45.585	2026-02-18 13:50:45.586568
3	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名修士	{"id": 1771440543442.0981, "name": "青命符文戒1·仙", "slot": "ring1", "type": "ring1", "level": 10, "stats": {"attack": 22, "critDamageBoost": 0.01, "finalDamageBoost": 0}, "quality": "epic", "equipType": "ring1", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 10}	青命符文戒1·仙	ring1	epic	100	\N	0	\N	0	24	cancelled	2026-02-20 22:07:48.245	2026-02-19 22:07:48.246647
4	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名修士	{"id": 1771440543442.0981, "name": "青命符文戒1·仙", "slot": "ring1", "type": "ring1", "level": 10, "stats": {"attack": 22, "critDamageBoost": 0.01, "finalDamageBoost": 0}, "quality": "epic", "equipType": "ring1", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 10}	青命符文戒1·仙	ring1	epic	100	\N	0	\N	0	24	cancelled	2026-02-20 22:07:53.23	2026-02-19 22:07:53.230891
5	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名修士	{"id": 1771440543442.0981, "name": "青命符文戒1·仙", "slot": "ring1", "type": "ring1", "level": 10, "stats": {"attack": 22, "critDamageBoost": 0.01, "finalDamageBoost": 0}, "quality": "epic", "equipType": "ring1", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 10}	青命符文戒1·仙	ring1	epic	50000	\N	0	\N	0	24	cancelled	2026-02-20 23:58:40.77	2026-02-19 23:58:40.771841
8	0x82e402b05f3e936b63a874788c73e1552657c4f7	无名焰修	{"id": 1771607035657.9148, "name": "星魂焰心链·天", "slot": "necklace", "type": "necklace", "level": 1, "stats": {"health": 107, "healBoost": 0.23, "spiritRate": 0.32}, "quality": "rare", "equipType": "necklace", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 1}	星魂焰心链·天	necklace	rare	100	500	0	\N	0	24	cancelled	2026-02-22 11:04:14.496	2026-02-21 11:04:14.497553
11	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	{"id": 1771704541204.6682, "name": "星晶护腕·仙", "slot": "wrist", "type": "wrist", "level": 43, "stats": {"defense": 65, "counterRate": 0.58, "vampireRate": 0.68}, "quality": "epic", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 43}	星晶护腕·仙	wrist	epic	100	50000	50000	0xc385d64735689929311621f4e81ca5b4e7830055	0	24	sold	2026-02-24 11:28:39.934	2026-02-23 06:28:39.934657
10	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	{"id": 1771694198345.4775, "name": "赤炎焰杖·圣", "slot": "weapon", "type": "weapon", "level": 1, "stats": {"attack": 38, "critRate": 0.15, "critDamageBoost": 0.6}, "quality": "legendary", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 2.5, "maxStatMod": 3.5}, "requiredRealm": 1}	赤炎焰杖·圣	weapon	legendary	100	5000	5000	0xc385d64735689929311621f4e81ca5b4e7830055	0	24	sold	2026-02-24 11:28:28.283	2026-02-23 06:28:28.284335
9	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	{"id": 1771681436107.8853, "name": "星系腰带·仙", "slot": "belt", "type": "belt", "level": 1, "stats": {"health": 175, "defense": 15, "combatBoost": 0.2}, "quality": "epic", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 1}	星系腰带·仙	belt	epic	10000	50000	50000	0xc385d64735689929311621f4e81ca5b4e7830055	0	24	sold	2026-02-24 11:28:10.469	2026-02-23 06:28:10.46965
12	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	{"id": "pill_ie_1771686644242", "name": "仙灵丹", "type": "pill", "effect": {"type": "allAttributes", "value": 0.5, "duration": 600, "successRate": 0.6}, "quality": "epic", "description": "全属性+50%，持续10分钟"}	仙灵丹	pill	epic	100	50000	50000	0xc385d64735689929311621f4e81ca5b4e7830055	0	24	sold	2026-02-24 11:31:22.652	2026-02-23 06:31:22.65361
13	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	{"id": 1771704541204.5015, "name": "太素衣服·圣", "slot": "body", "type": "body", "level": 42, "stats": {"health": 1438, "defense": 192, "finalDamageReduce": 0.92}, "quality": "legendary", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 2.5, "maxStatMod": 3.5}, "requiredRealm": 42}	太素衣服·圣	body	legendary	100	3000	0	\N	0	24	active	2026-02-25 06:12:49.441	2026-02-24 01:12:49.443047
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
63	1	0xadb0ecf47e175089579da5182dd7707328575909	机器人1号	200000	10	2026-02-21 23:08:05.496484-05
64	1	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	机器人2号	300000	15	2026-02-21 23:08:05.589516-05
65	1	0xf55dc98d490893d3e6be354bc01cdd7ca49e3eb9	机器人3号	250000	12	2026-02-21 23:08:05.712111-05
40	1	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	3271	34	2026-02-21 23:10:15.088103-05
\.


--
-- Data for Name: boss_rewards; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.boss_rewards (id, boss_id, wallet, rank, reward_stones, reward_items, claimed, created_at) FROM stdin;
1	1	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	1	50000	[]	f	2026-02-21 23:10:15.092276-05
2	1	0xf55dc98d490893d3e6be354bc01cdd7ca49e3eb9	2	30000	[]	f	2026-02-21 23:10:15.094644-05
3	1	0xadb0ecf47e175089579da5182dd7707328575909	3	20000	[]	f	2026-02-21 23:10:15.096441-05
4	1	0x82e402b05f3e936b63a874788c73e1552657c4f7	4	10000	[]	f	2026-02-21 23:10:15.097806-05
\.


--
-- Data for Name: bug_reports; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.bug_reports (id, wallet, player_name, player_level, type, error_message, error_stack, description, screenshot, browser_info, page_url, extra_data, status, created_at) FROM stdin;
1	\N	\N	\N	auto	test error				curl		{}	open	2026-02-23 04:44:46.527905-05
2	0xc385d64735689929311621f4e81ca5b4e7830055	无名焰修	23	manual			测试 bug 反馈	data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAASABIAAD/4QBMRXhpZgAATU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAxKADAAQAAAABAAACHQAAAAD/7QA4UGhvdG9zaG9wIDMuMAA4QklNBAQAAAAAAAA4QklNBCUAAAAAABDUHYzZjwCyBOmACZjs+EJ+/8AAEQgCHQDEAwEiAAIRAQMRAf/EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//EALUQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+v/EAB8BAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//EALURAAIBAgQEAwQHBQQEAAECdwABAgMRBAUhMQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0QoWJDThJfEXGBkaJicoKSo1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5+jp6vLz9PX29/j5+v/bAEMABAQEBAQEBgQEBgkGBgYJDAkJCQkMDwwMDAwMDxIPDw8PDw8SEhISEhISEhUVFRUVFRkZGRkZHBwcHBwcHBwcHP/bAEMBBAUFBwcHDAcHDB0UEBQdHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHf/dAAQADf/aAAwDAQACEQMRAD8A+C66/wD4QHxj/wBAqf8AIf41yFfbbXSfZA8ZZ5Au8heu04GSPQHP6dua5sXinRtZb3N6VLnufKf/AAgPjH/oFTfkP8aP+EB8Y/8AQKn/ACH+NfUy3cot2eSNweq4B5+vGAMc+tPs7p7iCWbaziMZ+XrnsB+fPXArzVmrbS5ToeFVr3Plb/hAfGP/AECpvyH+Nc5f2F5pd3JY6hE0FxFjcjdRuAYfmCDX2vZ3VtLbxs5BkbAIyc5MmOgPpXyh8Q5PN8Y6i/qYx+USCu7C4x1pctul/wAjGrS5Fc4uiiivTOYKKKKAJI4ZpjiFGcjsoJ/lU32K9H/LvJ/3wf8ACvofwPMLTwbYSaZGjPJI4uMDLbizKCcEdDtznota7apqMlyY2hxGDLlijjARyq49SRg4HXqK8KtmjhJxUNvM7YYa6TbPlqSKSI7ZUKH0YY/nTK918bSw3PhmSW9QJMGHlgjBDb8cZ9Vz+FeRaUjukwgH7/KhWA3Mq4bJAAJxnbkgZH0zXbhcZ7ak6nLazsZVaPJJRuY9FaeqqqzRjaFk2fvBgA53NjcAAAxXGRj685q5oaRt5pVVa4BHl8/MBtfJUc5OducAsOwz063UtDnsYqOtjAp4RiM8Ae5xWprSwJdKIQqkqd4Qg/NvbrtJUHGMgcfTpVWKGOaV1lkEaqmVJwM9MdfY59T9aanePMDWtits/wBpfzo2f7S/nV+SwhjXcLhH4UgKy9zjB+bjH4/lgmcafZbgDcrgyMn3gMDBwSfTIHP6eq9pEfKzJ2f7S/nRs/2l/Ol8psE5XhQ33l6E49evt1FXYbOBkzNMquJChUMvQKTkHOOTxnpVOSQkij5f+0v50wqVODWmbS02kiYHEbMPmAyy47Y4BHQdSfSs8/6sZ9eP60KV9hNWI6KKKsR//9D4Lrqf+E08TZz9tOT/ALEf/wATXMbm9TRub1NFSlTqW9pFP11LjOUfhdjqR438UqCq37ANwQETn/x2mjxr4nBBF8QRwPkj/wDia5jc3qaNzeprL6rQ/wCfa+5Fe1n/ADM6dfGvidSCt6QQcjCR9f8AvmsC9vbnULl7y8fzJpMbmwBnAAHAAHQVX3N6mjc3qaunQpU3eEEn5ImU5S0kxtFO3N6mjc3qa3uQNop25vU0bm9TRcC5Z6nqOn7vsF1Lb7/veW5XP1weauHxHr566jcn/to3+NY+5vU0bm9TWbpwbu4opSa2ZZur++viGvLiScr08xi2PpmqlO3N6mjc3qapJJWSE3fcbRTtzepo3N6mquIbTw+BggMB60m5vU0bm9TSAdvX+4v6/wCNG9f7i/r/AI03c3qaNzepoGO3r/cX9f8AGjev9xf1/wAabub1NG5vU0ALvX+4v6/40jMWOTRub1NG5vU0CG0U7c3qaNzepp3A/9H4LqfZg7QMnpUFXR/rfxqpAJ5Leg/SjyW9BXS+HdNt9W1aGxumeOFw5dowCwCoSDg+4Ga1Nf8ABeq6BGbp2iubUc+bEw4G4KNynBB5GcZAz1rK7GcN5Lego8lvQV12h+G7rXIbqeE7Ft42bJB5ZcHHTBznHByOv1xoLG5uJHjjXmPduz2KqzY+p2nFZKtFtxT1RtKhOMYza0exleS3oKPJb0FaYtZWjeRSpEf3huHTpnr61Zi0q6mMYUpiUkA7s8jBxgZPQg5AxyKv2hlYw/Jb0FHkt6CtW7spbNgshVvdTkDDMuPzU1KNMujbLdYG1l3Ac5I+btj/AGf884PaBYxfJb0FHkt6Cukl0G+hO1tp+8DgkgbFLHJxjoMj6j3xCdIu1kljYophO1iTx/F7eqkUvaruPlZg+S3oKPJb0Fa8dhPJJLEOGiJDcE8jPoD6Gj7DN9ma6YqsakAEnG7Oen5Gn7QVjI8lvQUeS3oK2E0+5d9oAH7vzMk4GNobqe/IFJd2E9k8iTFcxMFOD1Jz09htINHtAsZHkt6CjyW9BW0um3LWouxtEZ9Tg455APUZGOOp4HNSvo9zHIkTugLlR1PG7OM8ex6ZNHtB2ZgeS3oKPJb0Fbv9k3e6ReMxsqEHIyzAkAZHPTH1I7c0n9lXfkLPgYcZVQck8kduPfr0OR3we08wszD8lvQUeS3oK6OTQr2KeKBim6WQxggkgMDjkgfjx/jilc2UtqXWQqShUHB7sCR/LmhVLi5WY7RlRkgY/CoXUDkVoP8A6tvp/UVQf7v41rF3ERUUUVoI/9L4Lq5kCXJ6ZqnVt/vt9aqQG/ouqDR9Si1DYJhGHBTdtzuUr1wemc1bvPEt/fwzxXOwicFflAUKpdXxxycFBgkk4z1rlFRnyFGSKlNvKPMOARFjcQQQMnAwQcH8Kz5Slrsdj4e8Zat4atbu008Qsl4uD5q7ihxjcvIGfqCOOlc3HdTRMXR8MxyScHPOec+/X1rNpMVlGhCMnJLV7lOpJqzZptcyMnlkrtyTgKo5P0FTf2jd4ixLjyRtQgAEDrjIGcZ5xWNijFXyIm5qTXc9zjz33kdCcZ6luvXqxNSpqN2luLVZcRAMAuB/ECD2zyCaxqMUciC5tSaneS/6yXPXsP4htPb04py6tfI5kWbDHbzhf4QQMccdTnHXvWHRR7NBdmmt1KiyKrACXlhgc9R+HU9Kd9smMflbl2bduNq9Cd3p69+tZWKSjkQrmst7OhZlcAsgjPA5UAADp7Ci4vJ7ti9w4ZiFGcAcKMDoOwrKxRRyIdzbbVL6SNYpZjIiqqgPhsKowo5zwAOPSny6xqM7I81wzmNSi5wQFOeAOmPmP51g4oxR7NBzM2f7SvCxfzeSFHb+AYX8gaBqV2IlhEgCIGAAC8B+D270zStB1jXJDFpNpJclfvFR8q/VjhR+JrXv/Afi3TYjPd6c4QdSjJIfyRmNZv2adm0Ncz1RnNqt87iRpjuUsQcDq/Xt3qrLcyTktK24naCeP4RtH5Cs0gg4IwRSVpyIVy1IwCEZ5NU3+7+NPpj/AHfxrSKsIhooorQR/9P4Lq433j9ap1cb7x+tVIDd8NC1XVo7i9mSCG3UylmbByvTbjOWB5C45xitHxRqemavO0+l2roE2q8x2qHx1JjC8EnkEsTjIOeAOPqRZZFRo1YhW6jsawdNOSn1NFP3eVm9aarbQaW1iyZdtx38/wAbR8cHsqE/U4+u9qfiPSb5EYB95QBwV4H7uVeORyC+e3TrXn9FaWIudxa+JbC3uLy6a2MhvAPlPVMuxZQSTkc57ZwMjqa5eWa2N3dSoP3bs5jG0MOScdcYx7D8KpoyKGDLuJHBz0NR0JAzR+0wESrtA34CnbjAAxyFI+93x+tTw3lhFkmIsdq4O1eoCg9+5B/yTWPRQIsXUiSy7oxhdqgDHoAOwHfvVeiimAUUUUAFFFFABW14d0d9f1u00hG2faHwzeigFmI9woOKxa7T4d3MVp4y06aZtqhpFyfVo3UfqazqNqEmuxUVdpH17o+jWOlWEdhp8SwwRDAUfqSe5Pc96L2BHjZGGQRUsN2pQFTke1Zep6lFbwszMM44FfOznFx8z0IppnzP8QNIgt7pr2BQrbsPjvnv9a81r07xrqK3AkUHO4/1rzGvbwjbpq5x1bc2gVHJ938akpkn3fxrsRiQUUUVYH//1PgurjfeP1qnVxvvH61TAbS0UUrAJS84x60UuKLCuJijFOwaUKT2osMZilxUoic9FP5VILeU9Eb8jSCxWxUjs0m3cANo2jCgcD1x1PueatrZXDdInP8AwE1KNOuz0gf/AL5NTdFcrM9mZkWMgYTOMKAefUjk/jUeK0zp92P+WD/98moWs7gdYn/75NO6CzKOKMVZMEo6o35VGY2H8J/KmSRYp0bvE6yxsVdCCpHUEdDS7T6Gkx7GnYD1jSviNMsCxXrFJAMFh91vf2qPUvG0c6nMm8HsDXlfHoaTj0NcX1Kne5t7aVi5fX0l7Lvfp2FUaXj3oyK61FJWRi3fUSmSfd/GpMio5fu/jVICCiiirA//1fgurzfeP1qjV9vvH61bBjaOaWlxSJEyaMmlxS4oAQE+tSLu9TQq1YVKTKSEUN6n86txxTsMqGI9s0mRBC9wRkrgKD03Hpn6AE1mG+vGOTPJ/wB9GsXJ9DVKxvLBc/7f61KILn/pp+ZrNtbPxHe20l7YwXlxbw5DyxLIyLtG45YAgYHJyeBVO3n1S6mS3tZJ5ZpWCoiFmZiegAHJJrPU0ujdaC59H/M1Xe3uPR/1qC/s/E2lKj6pBe2ayEhTOskYYjqAWAzjvTLCz8RasHOlwXl4IsB/IWSTbuzjO3OM4OKabE7A9vP/AHX/ACNU3jZThsg+9Q/arr/ns/8A30atWtxLNKltOxkWQhRuOSpPAIJ6c9fWr52tzNpMqkGmYq06YPNREVuZMixRin4qUpH5QcN8+cbcdvWi4JFbBpadiigBvNRS52/jU9QzfdH1oBFeiiiqGf/W+C60SOTWdWqRzVsGR4qSMKXAfpRijFKwkW9Qjs0nxZMWjwOWGDnHNUwKXFSBaSVlYcnd3FVauLtMaxhAGDElxnJBxgHnGBjjAzyck8YhRatxrUSZpFDbvaumSJtBJljO7nIwH4645z6dvrXPV0moLjTm/wCuifyaub5rBPcuR6R4c1i+srGI6B+7kg1CR0R3JIWVY8LKy7NylYmzgDODxyBXZlrmaS5uYwBdX0jPcCGMQ7/MJJGQPmUbCQHJ55JLMWPmXhuWCCa41G7lig3Ixy2FAAOTtCg4yeAAPTAPAPd6TqWneKpk027up9GgmJ8logqs7ZURln+YjPUngYO0k8NWVTmbtFHXT5VFSky/apdW4bzB5MEhlEu7DIVQsxV0+YMOMEMNpIA5yMkmtapp82labCY49M0+VnACeSP3b+b++VWCkKFJBwDwSSWOTUi8N6R4RsW1A6neW8/mlY7ViCJQCFfK7VA6gbsg8EDnGOavdXtdZ0+4hbZBMMJLC3yt1+WRAdwwcZ+8cEgdcF4immnujR8sl2Z50xiKRhFZWC4clgQWyeQMDA24GCTyCc84E1l/x+W//XRP5ilDTRwyKm2MYEMoDcv8xfkE84KjlRgYGeTyWP8Ax+2//XVP/QhXS9mef1L8y/M31NVGFaUy/O31NU3Wt4vQiSK2KTFSkUmKsyER9gYbQdwxz2+lRgc9M1JijFFgIyKhuOgOMc9KtYqtc/dH1pjRTooopjP/1/gutvbxmsSt+4v5mhW2DfKAAeB0Haqd7qw9OpDasJLuJWGULjI9s81LcReVcSxDojsPyNLpIQ6jbrJ91mAP48Vq6kkkOo3CekhqHK0rDSujGCmpVQ+lW1nnHRsflVhLy7X7shH5UnJ9ilFFVInPRT+Va0el35jWT7PJsPIO01Guo3/aY/pU41HUD1nf86xk5GsbDNb06a10YTTYXfKmFJ+bo3JHauWt7+4trS6s4ljMd0FEhaNWYBTkbXILLz12kZ71v6tNLLpreYxY+anX6NXKR+WJEMylkDDcFO0kdwCQQD74P0qILR3Cb1Owtk0m4uLeXVVuLmwVRhYNnmkqm1AflYfKQAwHXJPOMH0TwL4Yh8V3M9wJnj0iCZJSg2l3kVXEa+aEB+RXbdgjqPlBOR5CdO1Gxu4rKQeVNdpE0akpscTAFCxY7QNrZyenfHOOotNM1CxvEeG4aB3Kg+QWhlYluMFZBuPTOWAGTg8GqlJJbmkYym9tT27WvBd3eac+qWTCDUbMzeVGkbOkkToVYGObzMvIrE9MDd5ZyV314JONAuLSJYYpzqULgCUMrQFACSrApnJG0Abm5JbjGD1mv2mpMBbf2pd3XyjetzLMyZKqW+V5WDbmztUjG0/MScFuC1SyuNNUx3EmxJEPlCJFAchhkMN25F2sT3BOBjqRFOUWtGVOnKDvJFbULryb8Swt5kyRiOQyhJF3bSmFBBGFTAGckMCQRxirZQumq29vMDE6zojBwQVIYAgjqMd6ff2c+miO3aeOWO5jjuMQyB1+YHAYA8OuSCDyOex5gsP+P+2/66p/6EKt7No53fm1Owm0yLcf9Mg6+rf4VQl05R0uIT+J/wAKWVfmb61WdKcb9ymkRPZlf+WsZ+jVAYCP4lP41OUppSt02YtIrGPHcfnTdtWdlJsqrk2K22ql2MKv1rU8s1n367VT6mncVjNoooqgP//Q+C6vkfMaoVonqavqJk9tIkbK4B8xWBznjA9sZz75rur3V70sJIpBtl3EZVTwDjuDXn6cE/Su2URT2umbejbo2+uf/r1hWS0bNafVEB1G+b7zqf8AgCf4VGbm5bqV/wC+F/wqbyfalENYXR0crK26RuuPyH+FOCsRzVoRVIIh60nIpRMfVRjTW/66p/Jq5Ou21eAtpkmw7ijK5A9BkH+dcrYtYLJm/V2TsEPf3/8ArU4PRmc1qaOhXJtbw3zyMGiQomCPmL/IVYkjapQsMjocDvXV3+rXOp3lpBbWHmyxhnMqhUdx3UHYSEx0DDqR8qng8zM+nSXW+zaKKA5Pl/MGBOcYZgT8uePmz6tW3pusiyXbbxwRdMszJlsdCxV+T7nmlKOvMb05JR5bmjq/iK+1K7ttSk0VBDYNHB5Df6oGM42lGXqGzjqv3VIJB3TNdWviC5FhqZuGjlPmLFHII3aRAdob5JFZjuYKyryXAyvQYlrrFxBNfPIYHW5leTBkUg7mYnA38Agjj+uayLi4jc+ZA0dqytwMgqo77Fj34z3IKnvmpjTStZWsU6is03ubXjbSvCmlxaX/AMIxPLObiJ5ZzK6swBK7AdoABHzBscZGM5Brj9O51C1A/wCeyf8AoQq9eNoxiVbcMZQvLLn5j77j+HA7D3qppUbSalaqO0qsfYKck/gBWr+FnI/iOue1kLE7G6+lMe0+YkRuFzwDgnH6VdaIEkhwfz/wqExH1rFSfc2aIDaxZ/1cmOO4/GlFva/xRSfmKeYjSeV7Vd33FZdh+zTAo3W8gPrvH+FXrbUdMtE2x6ejnu0nzGs3yh/dpyog6xBvqT/jSeu4WLL3umtJ5osUB9BnH5ZrnvE14l3HbBIUiCF/uKFznHp1xXQJLEnP2SIn33H+tc/4nupLhLZWVUVNwVV4AzjtVU176In8LOSooorvOU//0fgutE9TWdWieprQTHr1P0ro9NuA1vHGf+XZjLn23Ln9K50D+VXLKXypjk8MrIf+BAioqK6Kg7M7m0h+2W5uIsYMrgc44ByP0NT/AGGQdh+Yp3hUJPp5hY/P5pIHttGa6f8As/2ryqj5ZNHfB3Wpyv2Nh2o+zH0rqxYH0pfsB9Ky52XocqLcjt+dZsnh3TZGL+SUJ6hWIH5HNd19kjD+UfvkbgPUDgn8OKd9g9qfMxaPc4EeGdMP/LN/++//AK1Q3GgaZap57W8ssa/fCv8ANj1HHOPSvRRYe1a+o6LY2Wk3F8ZDvigeQJkclVye2cZx2qXVaauLljY8cS18FSRl1uJVOPusGB+mQCKxLNdDe6jW7V44SDubJPOTjAAzXTa74YtdH065upJJ2lF28MOdhUxqxUM+ORnY+DxkjpjmuW1bT4dPNuLefzvOjLlWTYyDewXcMtjcoDAZzg8j174KMtmzlba3RtNbeFZGEGnx3FzM/CgkoufUk84HXpW7a6Tb2a4t4grMMM3JJ/E9B9MVwej3403UYruRdyDKuO+1uDj3r2i2jt72Bbm0cSxMOCP6+hrOvFwt2NaUk9znPsjdAKT7FIeg/UV1JsPam/2dnotc3MzfQ5n+z5T2H5j/ABo/s+X0H5j/ABrpFsFcB4xuU9D60/8As4/3aHJoV0cv/Z8voPzFH9ny+g/Mf411H9m+1J/Z3tRzsNDl/wCz5PQfmP8AGuP8V27QLbbhjcX7+mK9Y/s32rzvx7bfZlseMbjJ+m2t6Em6iRnUtys86ooor1ThP//S+C60yOTWZWrjmtBMcOn4GlHWmbkAxuHel3p/eFAHZeFb3yNRtomOFd2B/wCBLivZBtr5ztrkW80c6tgowYfga9fXxNYThFtpQzsVyCCOD1xmvOrxs7pHRDU675aZDLFcRiWI5U9D9K5u41+ytflmkVSe3JP5Cs/TfEulwWqxPNgqT2bufpXOk7XsW4+Z1V/YLexDY5hmjO6OVeqt/UHuD1rz668X67o0htdUsY3dejjKhh69xWnD4usVv5Wkm/cvgDg8Y6Hp3qLW7rRNfgWFboRTpny2IYLk9jkYwa1jppJaEuPmc7ceNtYvI8QrHaq3TYNzfm3T8qzpNY1yfcZrudvMUIwz1AGOmOuCRnrzUN/ZSaLLDFfrHIWG4FCQCAemcdacdfgZ1cRxgjOeSck456cdK2ST1SJ26hNqeqXkcyXd5NLHOFWXzGL5CNvA5z0OSMep9TUOpS39+Yn1G4nlyP3TTOXIHpkk9ahfVIpg0bsNr4zz0IGM/d+v51NeX1rPbqgdAUzjAIzkk+nvRZpqyKWqZgSxeW+3nPfirVhqeo6ZJ5ljM0RPXHQ/UHg1Xe4ZmA+8oHAb0ppnX+4v5/8A166tbaoxsd5b/ETU41CXNtFOR3GUJ/DkV1ujX2s+IRvvLdbOxIz8pO+T2yei+pxz0rzGxsbafypbu7SGNuXjVW3Y9MgY5+teoweJtFs7dIlm+WNQqjDZwOnauaUop6RLUWdcrQq/2dMBkAO0dh2pxeNeTn8BmvOrLWDNfm/8wMsnynB4A7D8KtN4mshNKGuMjIxjJHTnoK5ZXbehqod2dhLdsuRFCze54qrNe3JYeTB8o67gef8ACuZHibTz/wAvH6N/hWIfFitqnyzEW2Nvfr60lCT6Fe6juoLu9SUtPGWRuwGMfSvPviPcGcWHyFAplxnvnZXT2+qw3uRbyhyOo7/ka4jxxIziz3HoZP8A2WrofxEmFSK5Wzz+iiivVOM//9P4LrXI+Vj7H+VZFbZHyH/dP8qsDMrsNE8D61rmnPqsPl29qrbFeYsA55zt2qxIGMEnAzwMkHHIV1/hLxVJ4clnhmUzWV0pEkY5IYD5XXJAyOh9vfFb0uRzSqbGNZ1FBunuZmt6Ff6DMtpfqPmAZHTJRgeuCQDweCCAf0qvaXAR4WJ5Vx+hFGratdazfS390fmfhVHRFHRR7D9TyeSapp/r1/3hWVVRbfLsa0nJRXPudBqsm7UJWHRgp/NQai02xutSuUs7NN8jn8FHdmPZR1JPSoL183eT3RP0UVseGfEl34c1Bby0PyuNkij+Jfr6+lZU4xulLY0qOXK3Dcl8TeFNR8L3gt7vEsbAFJkzsJIyR7EenpzXPCRhgelei+MfGI1uFNI0tTHp0eHw33mY8n3Cg9B6+2BXnZAXGe/A+tVWUVK0DOhKbgnUWpr+JZhLa2UbHLJArc++K5uz0y5v7iG1tQHlmbAHTHGSSewABJJ6Dmi9u7i5ERmOdiBBxjgdKo7m9KinFxikayabNXUdLSxu1tY5hNlQS6gbSSM/KVZsj3OD6gGqjWhVS24HHtUazOwVJSSqj5evy9+Pao98h/yavUnQ0pNPZNMS+3KVZtuB17mqAh2OmSCCRUheT7MEI+XP9TVbL5zUxT1uxtrod3B4evLi2eaGRd8cZkMZ4JUbQME8NnPAGTwT0wTzLbieetem6Z4t0iHw2bSTy/twgfDDzPlYDCqRs2kn1DY6V5xtLHPXPNVP2enJv1OqqoJR5GaGn5FpeeyD+RrKDcmtmy8tNPvg3LsqhR+eTWErBcnqR0rCK1Zi3oi3JE6W7TZ6Ace5/wAj86yORzV6K4ZGAkJaPOSvY/geKjumheUtCMKfbHetkrGTZq6JIWvE7cEH8ql8VnK231f+lUNHkEV/Gx6HIP4jFTeJblJ5EiQf6lmUn16Vg4/vU0a83uNHL0UUV1GB/9T4Lro1jDwy4PzRx7se3SucroI9sSlnyTKpGAccE468+lU79AJJrOFGiZAm0L+8xKjDJ3EYw3UAcjjJ49KuLY6U1wI2mijiFzs3FyxaMswGCueAAMkqOoPesuRbeRtxRgf94f8AxNN8q27q/wD30P8A4ms3Tm1uXzLsWoLC1JuVuJURQFMT7hyDIFJAJBPy5OMZ4qxLZaekZmhuEaQMCEyCQuUAHB5Y7jkjj5T07ZnlW3ZX/wC+h/8AE05Et0YNtfg5+8P/AImh05XvcOZdixdHz5yR99VUEewA5qWyhjIl+0IuAvDMSCCeBtAIzycnPYVUmFvM/mbXU8dGHb/gNMKRnhmlI/3x/wDE03BtWBSRrXy2tgJjCY5ozjyzuJcMWIxw2OilicY5A4zWE+osxQ7B8hz161Ibe2IGRIcerD/4mjyLbsrj/gQ/+Jpwg0tdQckyG9naeQSMApwBtXoAAB+uMmq0e1pEXnBIBG4D9TwPrWg0Ns2Plfj/AGh/8TTfs9r3V/8Avof/ABNWk0rWJuXbu1so4J3j2bkCKpWZGy/y7iF3ElfvY6nkdMEVhEr2JFaH2e1/uv8A99D/AOJpTBakABXGP9of/E1MYtKzG2mVmeP7OFBbdnr2xz2qsSOxOa0vIttu3a//AH0P/iaQW1r3D/8AfQ/+Jqkn2FcsW7WiaVMzMPOO7AJ54MYXA75DP+VVG1B2UKEAxT/s9r2WT/vof/E0pt7Xsrj/AIEP/ialQetx8xtaZbyyWd62QzBATyM4we1ZXkue350kaxRAhPMG4YPzD/4mkKRMMOZGHoXH/wATSUXd6A2i7ZxWMwk+0OF2j5TnGRhssPUggYHfNZWKu/6Nj7j/APfQ/wDiaaRb5BCuMc/eH/xNNRabYXQtk6Q3m5ukYJ+pA/xqlfMWwzdSSTVtFt1bdtc5/wBof/E1X1BAqxlTlW5BotZ6hcy6KKKsk//V+C635Okf+7/U1gV0EvSP/cH9a0W6DodFoHhDWPEttd3OliJhZoXdXkVCQo3HbuIB47ZyewNc/JaXMF01lPGYp0fy2ST5CrZxht2Mc9c1Z0vUZ9LvI7uAjKMDyAehByM9wRkHsa7Hxl4l0TxJJaaolvL/AGoG/wBMnZ+bkcEMw24Vx93gEYHeubnrRrcsleL2a6euvXuOXLpb5nI6lo2paTObe+h2OGZflZZBuRijDchYZDAjrWaUcLuKnHTOOOK9EufHkN1qM97JYybJnZ8eePMGblLlF3iMAhCpA+XPzE56AUtd1qw1DRkt7adllMkbvFyQ3Eh5yihTHv25UnfnJ9tIzqaKURuMejOebQ7yGBp7kpCoiWZQx3FldQy4CBsZBH3sDnkitOXwXr8NnNqBija3gLKzrKhB2B2bHOflCN/TOauTeKLKbTbjTDBMhmiSIXCuC4jiC7IShGPLyilvmyWG4YHymzL4ytzay2sNvJ+9RlMkjKzAm28j05G75x0K9ieSZcq3RDtDuef0UUV1mQUUUUAFFFFABRRRQAUUUUAFFFFABWnZ6ReX8QltAsihir848sYzufP3Uxn5unBzWZWrZavc6fF5NqqKHYmXIz5q4xsfPVPYY55PIGADMdQrsoYMASMjOD7jODUOoj9xbH2P/oRqZyGdmVQoJJCjOB7c5NRaj/qLb/db/wBCNRLoUjIooopAf//W+C66CbpH/uD+tc/XS3a7DEMY/dIfzGatfEg6EKRFxkGneQ3qKkh+5XQf2VELR7gyNuAQrgfKQwGck46FgOn+NbWJOb8hvUUeQ3qK6u40WGFsLI5/eCPkDH3iDyMjoV/X8K40yArb7ZSWkjd36cEbiFAGTn5fT19KLAc55Deoo8hvUV0o0qNrgxh2K7d4OB935TjIJBIDc/p1qaTRoFupYElJVMFSe4PGeAR97gDv9OaAOU8hvUUeQ3qK6M6ZAsQkMjZIGAMfxKSOpHQqfqOBzS/2UoG7cWUbst06EDgYP94d6dgOb8hvUUeQ3qK6i40mGC0+0bnJ2A84HPPt06VgUrAVvIb1FHkN6irNFOwFbyG9RR5DeoqzRRYCt5Deoo8hvUVZoosBW8hvUUeQ3qKs0UWAreQ3qKPIb1FWaKLAUWUqxU9qj1If6Nan2b/0I1NL/rDTNTH+h2h9Q/8A6Eayn0KRiUUUUgP/1/gut+XpH/uD+ZrAroJQAI8HPyD+tWviQdCWH7lXTd3LJ5bSsykBcE54GMDn02j8qpQ/cqWtyS019eMcmZ+uevGTTWu7h8bnyVBAPGcEYPPXuar0UAWFurhWLLIQSADjuAMYPtjtSteXLgqZCAwAIHAIHQEDFVqKALP2y5JU+Y3ykMB2BHTjpxmoxPKGDbjkDA+hqKigC0b25ZCjuWBGOQCcH3PNQNLIwIZyQeuT9T/U0yigAooooAKKKKACiiigAooooAKKKKAKcv8ArDS6qMafYn18z/0Kkl/1ho1SXdYWMWMGPzDnPXLVjPoVHqYNFFFAH//Q+C66N4ZGMUaqWYoCAOTzk/yrnK7GRzGiwDqqgOe5I7fQdP1rWKbkrD6EcVrKq4YoD/vr/jUn2d/7yf8Afa/412HhX4aeO/G8Mlz4X0ae+giO1pRtSPcOqh5Cqlh3AJNczrWh6z4d1CTStdsprC7i+9FOhRsdiAeoPYjg9q35elySp5D/AN5P++1/xpjxumCw4PQjkH6EcVVJp8U7RH1U/eXsR/noalphoSUUyZxFIUAyOoPqDyD+VR+ePSlcRPRUHnj0o88elMCeioPPHpR549KAJ6Kg88elHnj0oAnoqDzx6UeePSgCeioPPHpR549KAJ60lsFNvDcF+JCNwx0GXBI+gTJ+orG88elKLgqcqCO3B9aAOgs9KW7hSUOV3EA5HHzPtGM4zjknHTGDiqd/ZiylWMPvyCc/RmX8jtyPY1leePSjzx6UARS/6w0aoE+wWRCkN+8ySeD83GB2prtuYt60mpsDZ2i56B+PqxrGfQuPUxKKKKBH/9H4Lrrrg/vnbs53D6NyP0rka6vzUWOKGcEAICrDqM5OMdxW0ZWkO2h+jvwQ+JPgq1+GOkWt1qcWhf2eTazCdkiSSYMsjEPIMEuuSdpzhz3AI+b/ANpnxp4X8W+JNLi8O3KajLptqYrm+TaVlLEFQGUBW2/MTt+UFsDuB89sZLqGKJ75XigBWNHdsICSxCgjgEkk47k1CbNf+fmD/vo/4VSSTuSWb3VBf3sd20ENpsRU226bVO0YyRkcnuc59KoXs0c95PPCCsckjMoIAIBORwOBUn2If8/MH/fR/wAKmtxHZzJNtiuWQ5AZwE/9CBP6fjS0StEUYpKy2NhPD2t3ALROIVjQZV3K42JGze3AcE+gBPQEjEnS6tb+fT7mUyGBpInwSVJTIOM+444rp5fF2oSXJvEghjlkaR5CkxUEyoiHaA4KgbBtCn5eg4rmbud7vUbnUptifaHllKq4bBfJwOSTycUo36jdjJoooqhBRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABU+rRsunafIWBVxJgdxhu/wBagp2qSh7Oyjxgxq/Prlyayn0Kj1MOiiimB//S+DcJ6n8v/r1uPJ5qRP6oB+WRWDWyn+oh/wBz+prW2odDstJ0exubGOedC7vnPJGMEjtj0rTGgaX/AM8T/wB9N/jTtBH/ABKoP+Bf+hGrTNKJiMsF3Y46YwD/AENfPV69VVZJSO6nTg4JtFYeHtK/55H/AL6b/GnDw7pX/PI/99N/jWiGcS4JOPXHH0Hv61Gry7W3bgwTOcHk9eO1ZKvW/nL9lDsVB4b0n/nkf++m/wAa5/xFpNnp8ME1qpUuxVgSSOACOtdna+Z5jhyxHbd+XFYPjAYs7b/ro38hXXha1R1VGUroxq04qF0jz+iiiveOIKKKKACiiigAooooAKKKKACiiigAooooAKiv3jMVvHggqpJPXOWNS1TvvvRf7n/szVElsUinhPU/l/8AXownqfy/+vTaKLAf/9P4LrZT/UQn/Y/9mNY1W7a4ljZYww2E8ghT9cbuBWr7gdhp/iCSxtVtfJEgQnBzjgnPoe9Xv+Escf8ALsP++/8A61U7W50EXU63TL5RbER2ggDLDJ2j/dPUfh34831yCRlOP9hP8K4lTpVJNuGpq3KK0kd6PFrj/l1H/ff/ANanf8JfJ/z6j/vv/wCtXn/2+59U/wC+E/wo+33Pqn/fCf4Vp9VpfyE88u56D/wmEg/5dV/77P8AhWTq+uS6skUTRCJYyW4OSSeK5q3v5DMomKbD1yi/0FaL31sY5NuwN/DhR/cHqP72fX+VVGjTg7xjqJybVmytRVH7fc+qf98J/hR9vufVP++E/wAK6Lsmxeoqj9vufVP++E/wq1Z3/wC/X7WV8rnOEXPt2ouwsSUVK95F5L+WV3gkg7U/LGP8frWZ9vufVP8AvhP8KSkwsXqKo/b7n1T/AL4T/Cj7fc+qf98J/hTuwsXqKZaX2ZD9pK7cDHyL6jPb0zSm+P2diCnmg8DaucZ6/dx+H40uZ9gsOoqj9vufVP8AvhP8KPt9z6p/3wn+FO7Cxeoqj9vufVP++E/wq/Y3sZZvtjKBwF+Rfx6ChthYSqd996If7H/sxrQmvoDaZgK+d8mQUHHB3Y4x1xWG7vIxdzlj3pXuFrDaKKKYH//U+E9i+lXTbQh5Bt+7uxyewNVK0n/1kvvv/ka2Ap2sEDyfv22RKMsQRux0+VSRuOT93v3IGSNbXptDvtSlvdDsf7Ns3K7bUTPN5fygcPJh3yQWJIGCcYAAzl21vNdSiG3Xc5BPJAGAMkknAFRurxsUddrA4II5BFXYDZvY9BMaiy2hxLgk+YcptHPOMnOemPxrNvhZO6PZxiNSCSoLHBLtgZYnouOlVvmHBH6UZI6jH4UlEZHsX0oCoOq5/OpMtjOP0pynJ57D0FMQxY4ifu9qb5aelSK5Hpz7UvPt+VFgIQidxT/Lj9Kfz7UoJFFgGeVH6frSGOP0qbeynKcH1FM5/wAiiwEXlp6UmxPSpuf8ijn/ACKLAQ7F9KesUZOCKf8A56UuSP8A9VOwEOyP0qe0it3uoknZI42YBmcOVUdyQnzHHtzSd+35Udf/ANVJxumhp2dzoRaeH/7QlaSaJbOQMsewzMyYxhsFAWJ54OAeeRxT3t/DBtlXzEWUW7lmXzj++BlKYDDBDfIDnG3OeSGrm+f8ikweuP0rjeEbt+8l9/8AwDo9sv5ULDFAd/mDOF4+uaY0UYXIHcVNCud3+7/UUSrtT8R/WutrRs5irsX0o2L6U6ipA//V+Fa1ZcGR8ccN/I1lVvpaiXzpGcLgOcd+hra6WrGjLtLy5sZvPtXMb4IyOcg9iDwa0L6fTLi3jmiD/bHfdNu+6eBuPHYtyMe/QYrKdDGeDT54Lq1lMFzG8MgAJRwVbDAEcHnkEEe1Xa+ojo5tasWdZkSTcGLAAAAEiToAcAgsvP49axtUvo9QnWdEKHZhgcddxPGOwBAH5VFJZ38Kq0sMiBjgEqRk4DfyIP0NMFreNJ5IikMn93ac9cdPrxUpJajKueOtOGdnHrT5Y5oZGimDI6nBVsgj8KZvYd6oByrngU4rg4pvmSCjzn9aWoaEiRlzgY/Himkc0glkpTI5707MNBCAKbTtzetLk+tNIBmKKdub1o3N60xDaKdub1o3N60ANqzZzJb3Mc0i71RgceuD9RVfc3qavzaZqtuoe4tZ41ZtgLIwBbGcDI645+lJtLRsduxLHeWyL91skg9MgYKn+97H9KGvLb7G1qisDgAHA7c8nPqT+lVpbK/hl8mWGRXOcKVOTjrj1pRY6gyCRbeUo0ZlBCtgouctn+6MHJ6cGpvHe4WZFb4y2f7v9RST/c/GiDq3+7/UUT/c/GrfwsRUooorID//1vhWtd2IeT6N/I1kVqufnk+j/wAjXTHqBf8ADOoabpmswX+r2ovraHJMDpvVyRgbhuTgZ3YzyRjjOR0fxL8anx5r0esBZiYoEhV7jaZCqjOG28EBi2CfmIxuLHJPF6Zp1zq9/Dp1mAZZjgbjgDAyST6AAnjn0BNWNa0efRNQewnO8jlWAxlSSBx68c4JGehNZ3iqlubW23kdH1aq6P1jl9xO1/O2w+51h7uOGKaJmWJtxDMW3cAc5GM4GM+gHuSqay8dxLdLEfMnXD4woDbt+4BQP4gCM9OfYis2j6gpRWix5jBByOrAMM88cHJz0qjPbTW5USrtLDcOnTJH9KvlXQwuPu52urh7jZs384AHXHsB161XVWJyRTKUUxFjLHtUew5zg0lFNKwxdreho2t6GgkkAelJVCF2t6Glw3oabRQAu1vQ0bW9DSUUALtb0NG1vQ0lFAD1GGBYHGecV6ffeOtKupkuYdKeF45zcKN6kK4SQR4wi8qzKckc7QMYHPltbVl4d1nUFL2tqzKIzKWOFAQFRkkkAcuvX1FcmIpUp2lVe3nbc1pymtIm1d+KIZ7qC6isjHstntnAfkqy4G1gvGOvTuRU994qtL61dHspEnkjlQsr4VfMLOAFx93exJ74x6HNGPwL4ql84Q6fJI0EjxMq4Lb0IBAA5PX8Rk9Aaxn0XUorH+0ZIdtvtDbiy9C7R9M5++rDp29KwjTwsrcslp5/8Etyqq91+BSg6t/u/wBRRP8Ac/GiDq3+7/UUT/c/GvSfws5ypRRRWIH/1/hWtV/9ZJ9H/kayq1HOJWP+0a6YbsBdJ1OfR9Rh1K2AMkJJAPTkFT+hq1rmtSa3cJcSQrEVGPl5/DPHA7Dtk1ntHFngH8//AK1J5UXo35//AFqToxc/aW1OpYuqqLwyl7jd7een+SLT6tcOYjsQeU24YB5OAvPPTAqncXUtyI/OwTGuxSBj5R0HHHFO8qP0b8x/hR5UeeA35/8A1q05X2OW5Vxmirgt0PYj8f8A61P+zRf7X5//AFqrkl2FdFEqwAJHB6Gkq/8AZ4vf8/8A61L9ni/2vz/+tT5JdgujPxS4q/8AZ4v9r8//AK1H2eL/AGvz/wDrU+R9guUMUYq/9ni/2vz/APrUfZ4v9r8//rUcj7BcoYoxV/7PF/tfn/8AWo+zxf7X5/8A1qOSXYLlDFGKv/Z4v9r8/wD61H2eL/a/P/61HI+wXKGK6VPFOopYS6ftTZLEkRIzkiMxbSeSDhYgvQcE55rJ+zxf7X5//Wo+zxf7X5//AFqznQU7c0dilNrZnVx+P9VhumuUjT57qS6K9ATJjKkjBKjGOe3TFU5PFskmltpZsYAGjSPzMHcAkewnrjLE7z/tc9awPs8X+1+f/wBak+zxe/5//WrBYCmtVAv20u5Xg6t/u/1FE/3Pxq2sUaAhc89SarXK7UH1rplFqLuZX1KVFFFc4z//0PhWtV/9YxPbcfy5rKrYdTukPs38jXVDqBnmWUnO4/nR5sv99vzrd8M6Pba3qRsrqb7Ogikk8wtGiAouR5kkrKqL2zyScKFJYV1HjXW9Njth4O0KzFtZ2d0000jbTJLMEES52jKqig/KWY7mYkk1mqtN1HS62udDoT9j7dbXt/Xrrb0flfzvzJf77fmaPNk/vt+Zr1+11nwi82nJcxwIIpLSV+oAULbBhu2MSylHVgSBtyc7uDm63feHJbLw/HaPApsjI13NAu2U/vWcIFIGTj7pIwcjkAHHJHFycknSav8A5N/pb5g6Ss3zHmfmy/32/OjzZf77fnXY6k+gtb3t3p0kEb3s0E8UJRibdWE3mwjKEYRtoBHVdp65AwddlspNe1CbTghtGupWhCLsQx7zswuBgbcYGBiuunV5nbla/pf5/gYyjbqZnmy/32/OjzZf77fnUdFdFiLknmy/32/OjzZf77fnUdFFguSebL/fb86PNl/vt+dR0UWC5J5sv99vzo82X++351HRRYLknmy/32/OjzZf77fnUdFFguSmaZsZc8DHWk82X++351HRSsFyTzZf77fnR5sv99vzqOinYLly3kdiyuSwxkZ+tNu/uD60lt99v93+opbv7g+tU/4bDqZ9FFFcoz//0fhWtx+sn+638jWHW4/WT/db+RrspdfQTMtV3H2FP2p7/nSR/wAX0/qKdTATanofzo2p6H867LRvC8fiPSJ30adpdatWLtp+3LTwY5eAjlnT+KPGSvIPGKi8R+HoPDMdtZXN15msEb7qCPBS2z0jZu8n94D7p4560AcltT3FIE5IJ4FOpf731H8qBjdqeh/Ojanofzpa7XQPBlzrVi+oSTpbw8iPd1Yg4J9ABz35x261lVqwpR5qjsjswmCr4qp7LDx5na/yOJ2p6H86NiH1FWLmB7Wd7eXh4zg/WoK1VnqjklFptNajQnXd24pdqeh/Onnq/wDvU2gQm1PQ/nRtT0P519G6L+z/AH2oaFHf3lxex3lzGssaQWE00Kq3Iy4A3bgRhlwM5xuAzXg+taPe6DqdzpV+hWW2lkiJ2sqv5bshZd6q20spxkA+oByKyhVhNtRexpKm0kzK2KeBkGkRVPL5x7etSL94fWmj7n4n+lamYm1PQ/nRtT0P50tb2jeF/EHiGC+udEsJr2PTo0kuDEpbYJHCKMDksxPCjJIDHGFYgEYG1PQ/nRsU9Mg0tOX7w+tAxbb77f7v9RS3f3B9aS2++3+7/UUt39wfWrf8Ni6mfRRRXKM//9L4VrcfrJ/ut/I1h1uP1k/3W/ka7KXX0EzNj/i+n9RTqbH/ABfT+op1UNHQ6Hrs3hyQ6hppAvmR0jk2jdAWBXehIPzYJAPbqMHBFLVb5NUuH1BlWKeZyZEjQKmTyWGMAEnOQAB6YHFX4dEgm0tb4XGJCM7NpI+/txxz6Hp2NQ63pMOltEIJTMsgJ3EYA5OB+n49ajmVx2MKl/vfUfypKX+99R/KrEJXpXh7xbp9noyaPe7oggYFwu4EM5Y9MnODjpXmtdHFo1rLZ2tz5zKbh40II6F3ZTjGemw9cVy4mhCrFRn3PTy7Ma2CqSq0LXaa17P/AIYzNUuIrvUJ7mHJSVt3Iwckc8fXNZ9X76zjtPKMUomWVN2V6Dn7uc9R36VQrogkopI4Kk3ObnLd6jj1f/eptOPV/wDeptNGZ9T2vxP8OWtgthHqVmY/sz27Z06VWImjSOViVb/WOqKC4+b0Iyc+CeNdYsdc8SXmp6fvaKd3cvJ/HI7M8jquBsRnYlVOSB1NVrrQkt7EXizZBjjkOQMDfjIypPc+lZWpWkdleSW0UglVGIDD2JHPvWFOnTi24rc3qV6s0ozk2ltd7FNfvD600fc/E/0py/eH1po+5+J/pW5gFfR3gb4k+FvCPh240+1mlhmaEq+I2V7hiD8rFdylQSdu8HarOFwXyvgWl2cN/dfZ5pGiBRipVc/MB8oOSABnGT2FX5tJtkmvEhlZ0t32puBVmHXlQG+6AS2CawqwU7Jtq3YLGXfvbyXkslrxG7FgANoGf7o7D0HYcVVX7w+tbuqaTb2Nss0MzSN5jIwIAGMsARgnrtOc4/wwl+8PrWyd1cEraC2332/3f6ilu/uD60lt99v93+opbv7g+taP+GxdTPooorlGf//T+Fa3H6yf7rfyNYdbj9ZP91v5Guyl19BMzEYKTnoRin5X+8P1psYGSfQU/c3qaY0Jlf7w/WjK/wB4frTtzepo3N6mjUBuV/vflSBxk54Bp25vXP1pAACxA6Yx+NABlf7w/WjK/wB4frTtzepo3N6mjUBuV/vD9aMoOpz9Kdub1NJuPfn60agNDgk7uMnNLlf7w/WgAKWx2OKdub1NADcr/eH60p2cfMP1pdzepo3N6mjUBoZVOc5xTVYYweOc1ICWIDcg01OFyOucUAGV/vD9aMr/AHh+tO3N6mjc3qaNQG5X+8P1o3KvIOTTtzepoBLHa3OaAFtvvt/u/wBRS3f3B9aS2++3+7/UUt39wfWrf8Ni6mfRRRXKM//U+Fa3H6yf7rfyNYdbj9ZP91v5Guyl19BMzY/4vp/UU6mx/wAX0/qKdVDR1fhPwxJ4jvW8+T7Lp9rhrq4wDtBzhEBIDSvg7FyBwWYqisy6PjbxHp2ryw6ZpFpFDYaePLtmABdUA5jDgKXTdl9zgsXLNkbiK56PxBqUOitoMLiO2eRpG25DNuCgg84wdoyQMnoSQABiViozc3KT06L9Wc0Y1HUcpvRbL9X+i6fkUv8Ae+o/lSUv976j+VbHSJX2hoHgWw1Dw34Xuo9FsGN1ZxNIz2yM5fEeXf5l3hhk4OD15yRj4vr1Kw+M/wASNLsLLTLHVEjt9ORYrdTa2zFUQBVUs0RLAAfxE1pCVr62uuhxYujOrGKg1o+ps/Gfw9FoF/ZRxWVvaea9zzbRrGrKrKFyoLYIHbPGeK8UrrfFfjnxN42mgn8SXSXLW2/y9kMUIG/G7iJEBztHWuSqZWvp+O5tQhKFNRlv5Dj1f/eptOPV/wDeptQjc+3/AIY+HIfC/hG70rWfCb6jc3RLTXEVn9rF3HuUiFJJAPJAUMpIB+9uUhlBPyN4t8PXnhrWJLG8h+zmQGVIiWLRozMFVtwB3DGD/Oum1D4qa/qa2q3VpZH7IhjU+W5JDEn5iznuSRjAGa5bxR4n1DxbqjavqSRpMy7SIgwX7zMT8zMeSx71nGDTvfcwhBqTfc55fvD600fc/E/0py/eH1po+5+J/pWhuFfQHwn1fR7Dwxq8V6sZIkZ7rcm7dAYwAG4O5eH+XnqeOefn+u4tfH2r2MCW1pBbQxR/dVUYAf8Aj/X3rooyUZXZzYiEpx5Yo4g4ycdKVfvD61e1PUX1S6N5JDFC7D5hEpUE+pBJ5PeqK/eH1rB+R0K/UW2++3+7/UUt39wfWktvvt/u/wBRS3f3B9ap/wANh1M+iiiuUZ//1fhWtx+sn+638jWHW43LMPXI/Piuylu/QTM2P+L6f1FOpPKmQ/cP5Zp2Jf8AnmfyNMZvpqdh/ZYsZIMSbfvhQfmBJByTnBDEHpjrz0FTUb+G9UbIhGRLI/8AwFtu0dT0we1ZeJf+eZ/I0Yl/55n8jUpLcdxKXu31FGJe0Z/I00JMCTtbnrxVXELXTprGnfZUgktySphzwMFUC+YDgjliMgnPpjkmuZxL/wA8z+RoxL/zzP5Gk0mO5r6xf22oTJLaxeSoXG3AGMccEdRgd/61j0uJf+eZ/I0Ym7RkfgaFZKwgPV/96kpFSZeiHn2p2Jf+eZ/I0wOnXVNI+yw27WzAqgV2CqfmwQSMnnJOefQVjajcwXdx50CbAwJYYA5LE9uvBFUcS/8APM/kaMS/88z+RqUkh3FX7w+tNH3PxP8ASlxN2jI/A01UmX+A4+lUIWtZdQiD2jmJc22G6dSrEhev3TxnIznJ6k5ysS/88z+RoxL/AM8z+RpOzAkm8nzWNvu8s8gN1Ht1PTpnv7VGv3h9aMS/88z+RoImxgIR9AaYDrb77f7v9RS3f3B9adbxupZnBUYwM/Wm3f3B9at/w2LqZ9FFFcoz/9b4VrbJDEsOh5rEqVJpEGAePSuqnPldxM1aKzftMnt+v+NH2mT2/X/Guj267C5TSorN+0ye36/40faZPb9f8aPbrsHKaVFZv2mT2/X/ABo+0ye36/40e3XYOU0qKzftMnt+v+NH2mT2/X/Gj267BymlRWb9pk9v1/xo+0ye36/40e3XYOU0qKzftMnt+v8AjR9pk9v1/wAaPbrsHKaVFZv2mT2/X/Gj7TJ7fr/jR7ddg5TSorN+0ye36/40faZPb9f8aPbrsHKaVFZv2mT2/X/Gj7TJ7fr/AI0e3XYOU0qKzftMnt+v+NH2mT2/X/Gj267BymlVO7I2qvvmoftMn+c/41CzM5yxyaznVUlZIEhtFFFc5R//1/hWiiitgCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP/Q+FaKKK2AKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA/9k=	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	https://test.23.95.222.209.sslip.io/#/	{"playerName": "测试 2", "playerLevel": 23}	open	2026-02-23 04:47:23.744417-05
3	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	71	auto	TypeError: undefined is not an object (evaluating 'e.type')	@https://test.23.95.222.209.sslip.io/assets/js/WheelGame-DhGgeC0o.js:1:2641			Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	https://test.23.95.222.209.sslip.io/#/	{"playerName": "测试账号 1", "playerLevel": 71}	open	2026-02-24 11:27:34.695334-05
4	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	74	auto	Uncaught TypeError: Cannot read properties of undefined (reading 'type')	TypeError: Cannot read properties of undefined (reading 'type')\n    at https://test.23.95.222.209.sslip.io/assets/js/WheelGame-C9cECCzv.js:1:2676			Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	https://test.23.95.222.209.sslip.io/#/	{"playerName": "测试账号 1", "playerLevel": 74}	open	2026-02-24 21:09:50.514365-05
5	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	74	suggestion			[💬 其他] 测试\n				{}	open	2026-02-24 22:02:47.244847-05
\.


--
-- Data for Name: daily_dungeon_entries; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.daily_dungeon_entries (id, dungeon_id, wallet, player_name, result, rewards_earned, entry_date, created_at) FROM stdin;
32	1	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	victory	{"items": ["灵草"], "cultivation": 500, "spiritStones": 4000}	2026-02-21	2026-02-21 14:54:24.214509
33	1	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	victory	{"items": ["灵草"], "cultivation": 500, "spiritStones": 4000}	2026-02-22	2026-02-22 01:54:59.769489
34	2	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	victory	{"items": ["丹方碎片"], "cultivation": 2000, "spiritStones": 10000}	2026-02-22	2026-02-22 01:55:06.028796
35	2	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	victory	{"items": ["丹方碎片"], "cultivation": 2000, "spiritStones": 10000}	2026-02-22	2026-02-22 01:55:10.816893
36	1	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	victory	{"items": ["灵草"], "cultivation": 500, "spiritStones": 4000}	2026-02-22	2026-02-22 01:55:15.335828
37	3	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	defeat	{}	2026-02-22	2026-02-22 01:55:19.42225
38	1	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	victory	{"items": ["灵草"], "cultivation": 500, "spiritStones": 4000}	2026-02-22	2026-02-22 02:02:05.081144
39	2	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	defeat	{}	2026-02-22	2026-02-22 02:02:08.298273
40	3	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	defeat	{}	2026-02-22	2026-02-22 02:02:13.618484
41	1	0x7c402b2d8c7d48414d5f1eb4dd6522d04992c023	野猪佩奇	defeat	{}	2026-02-22	2026-02-22 12:25:48.040373
42	1	0x2f3a3513f2973a66e26850cc7a1baab6363d1b8f	索罗斯二世	defeat	{}	2026-02-23	2026-02-23 04:38:57.831744
43	1	0x2f3a3513f2973a66e26850cc7a1baab6363d1b8f	索罗斯二世	defeat	{}	2026-02-23	2026-02-23 04:46:02.826249
44	1	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	victory	{"items": ["灵草"], "cultivation": 500, "spiritStones": 2000}	2026-02-24	2026-02-23 23:44:20.62037
45	2	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	victory	{"items": ["丹方碎片"], "cultivation": 2000, "spiritStones": 5000}	2026-02-24	2026-02-23 23:44:27.043108
46	3	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	defeat	{}	2026-02-24	2026-02-23 23:44:32.673761
47	2	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	victory	{"items": ["丹方碎片"], "cultivation": 2000, "spiritStones": 5000}	2026-02-24	2026-02-23 23:44:52.573739
48	1	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	victory	{"items": ["灵草"], "cultivation": 500, "spiritStones": 2000}	2026-02-24	2026-02-23 23:44:56.734917
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
208	2	legs	119	2026-02-24 21:24:02.345085-05
209	2	feet	120	2026-02-24 21:24:02.966801-05
210	2	shoulder	121	2026-02-24 21:24:03.582479-05
211	2	hands	122	2026-02-24 21:24:04.212345-05
212	2	wrist	123	2026-02-24 21:24:04.827753-05
213	2	necklace	117	2026-02-24 21:24:05.450564-05
214	2	ring1	124	2026-02-24 21:24:06.069945-05
215	2	ring2	125	2026-02-24 21:24:06.693747-05
216	2	belt	126	2026-02-24 21:24:07.31872-05
217	2	artifact	43	2026-02-24 21:24:07.944364-05
167	13	legs	79	2026-02-22 02:35:30.468891-05
168	18	body	105	2026-02-23 04:42:35.756402-05
169	18	feet	106	2026-02-23 04:42:36.141351-05
170	18	shoulder	107	2026-02-23 04:42:36.433816-05
171	18	hands	108	2026-02-23 04:42:36.836969-05
172	18	necklace	109	2026-02-23 04:42:37.14525-05
173	18	ring1	110	2026-02-23 04:42:37.436115-05
174	18	belt	111	2026-02-23 04:42:37.729823-05
205	2	weapon	112	2026-02-24 21:24:00.483337-05
206	2	head	113	2026-02-24 21:24:01.095945-05
207	2	body	114	2026-02-24 21:24:01.723078-05
\.


--
-- Data for Name: equipment; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.equipment (id, owner_id, name, type, slot, quality, level, required_realm, stats, is_equipped, equipped_slot, enhance_level, created_at) FROM stdin;
\.


--
-- Data for Name: event_claims; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.event_claims (id, event_id, wallet, claimed_at) FROM stdin;
3	6	0x82e402b05f3e936b63a874788c73e1552657c4f7	2026-02-21 15:30:20.711899-05
4	6	0x2f3a3513f2973a66e26850cc7a1baab6363d1b8f	2026-02-23 04:43:33.718533-05
5	6	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	2026-02-23 13:15:14.419184-05
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.events (id, name, type, config, starts_at, ends_at, active, created_at, description, rewards) FROM stdin;
6	开服庆典	login_bonus	{"dailyStones": 5000}	2026-02-21 04:17:15.214367	2026-03-23 04:17:15.214367	t	2026-02-21 04:17:15.214367	开服期间每日登录领取5000焰晶！	[{"type": "spiritStones", "amount": 5000}]
\.


--
-- Data for Name: friend_gifts; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.friend_gifts (id, from_wallet, to_wallet, gift_type, gift_value, message, claimed, created_at) FROM stdin;
1	0xbot0000000000000000000000000000000000a1	0x82e402b05f3e936b63a874788c73e1552657c4f7	spirit_stones	500		t	2026-02-21 01:50:17.488882
2	0x82e402b05f3e936b63a874788c73e1552657c4f7	0xc385d64735689929311621f4e81ca5b4e7830055	spirit_stones	100000		t	2026-02-23 06:25:44.972761
\.


--
-- Data for Name: friendships; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.friendships (id, from_wallet, to_wallet, status, created_at, updated_at) FROM stdin;
1	0xbot0000000000000000000000000000000000a1	0x82e402b05f3e936b63a874788c73e1552657c4f7	accepted	2026-02-20 23:34:08.028796	2026-02-20 23:34:08.028796
2	0xbot0000000000000000000000000000000000b2	0x82e402b05f3e936b63a874788c73e1552657c4f7	accepted	2026-02-20 23:34:08.028796	2026-02-20 23:34:08.028796
4	0xbot0000000000000000000000000000000000a1	0xbot0000000000000000000000000000000000c3	pending	2026-02-21 05:56:47.766867	2026-02-21 05:57:00.762578
5	0xc385d64735689929311621f4e81ca5b4e7830055	0x82e402b05f3e936b63a874788c73e1552657c4f7	accepted	2026-02-23 06:24:10.058414	2026-02-23 06:25:09.525208
\.


--
-- Data for Name: idempotency_cache; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.idempotency_cache (key, status_code, response, created_at) FROM stdin;
idem:0xbot0000000000000000000000000000000000e5:wear:test-1771745730447-0.7222874375145742	200	{"items": [{"id": 1771671531638.7888, "name": "灵猫", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 5, "strength": 6, "constitution": 2, "intelligence": 6}, "experience": 0, "description": "敏捷的小型焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 11, "health": 103, "defense": 8, "critRate": 0.07, "stunRate": 0.09, "comboRate": 0.08, "dodgeRate": 0.06, "healBoost": 0.08, "critResist": 0.08, "stunResist": 0.08, "combatBoost": 0.08, "comboResist": 0.06, "counterRate": 0.07, "dodgeResist": 0.09, "vampireRate": 0.08, "counterResist": 0.05, "vampireResist": 0.05, "critDamageBoost": 0.08, "resistanceBoost": 0.09, "critDamageReduce": 0.05, "finalDamageBoost": 0.06, "finalDamageReduce": 0.06}}, {"id": 1771671531805.5637, "name": "草兔", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 2, "strength": 6, "constitution": 7, "intelligence": 9}, "experience": 0, "description": "温顺的兔类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 9, "attack": 11, "health": 104, "defense": 7, "critRate": 0.07, "stunRate": 0.07, "comboRate": 0.1, "dodgeRate": 0.06, "healBoost": 0.09, "critResist": 0.08, "stunResist": 0.06, "combatBoost": 0.08, "comboResist": 0.06, "counterRate": 0.08, "dodgeResist": 0.09, "vampireRate": 0.06, "counterResist": 0.06, "vampireResist": 0.09, "critDamageBoost": 0.06, "resistanceBoost": 0.07, "critDamageReduce": 0.07, "finalDamageBoost": 0.08, "finalDamageReduce": 0.08}}, {"id": 1771671531894.8552, "name": "火凤凰", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 1, "strength": 6, "constitution": 7, "intelligence": 3}, "experience": 0, "description": "浴火重生的永恒之鸟", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 26, "attack": 32, "health": 348, "defense": 24, "critRate": 0.08, "stunRate": 0.15, "comboRate": 0.16, "dodgeRate": 0.13, "healBoost": 0.1, "critResist": 0.13, "stunResist": 0.14, "combatBoost": 0.08, "comboResist": 0.15, "counterRate": 0.13, "dodgeResist": 0.14, "vampireRate": 0.14, "counterResist": 0.12, "vampireResist": 0.09, "critDamageBoost": 0.15, "resistanceBoost": 0.1, "critDamageReduce": 0.14, "finalDamageBoost": 0.11, "finalDamageReduce": 0.11}}, {"id": 1771671531976.277, "name": "风隼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 2, "strength": 5, "constitution": 9, "intelligence": 3}, "experience": 0, "description": "速度极快的飞行焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 18, "attack": 28, "health": 237, "defense": 15, "critRate": 0.09, "stunRate": 0.07, "comboRate": 0.11, "dodgeRate": 0.08, "healBoost": 0.12, "critResist": 0.13, "stunResist": 0.13, "combatBoost": 0.11, "comboResist": 0.07, "counterRate": 0.09, "dodgeResist": 0.08, "vampireRate": 0.13, "counterResist": 0.07, "vampireResist": 0.13, "critDamageBoost": 0.09, "resistanceBoost": 0.1, "critDamageReduce": 0.13, "finalDamageBoost": 0.13, "finalDamageReduce": 0.12}}, {"id": 1771671550219.3088, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 10, "strength": 9, "constitution": 8, "intelligence": 5}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 15, "health": 105, "defense": 7, "critRate": 0.09, "stunRate": 0.09, "comboRate": 0.07, "dodgeRate": 0.06, "healBoost": 0.05, "critResist": 0.1, "stunResist": 0.06, "combatBoost": 0.08, "comboResist": 0.06, "counterRate": 0.06, "dodgeResist": 0.09, "vampireRate": 0.05, "counterResist": 0.1, "vampireResist": 0.06, "critDamageBoost": 0.06, "resistanceBoost": 0.07, "critDamageReduce": 0.08, "finalDamageBoost": 0.08, "finalDamageReduce": 0.07}}, {"id": 1771671550219.8062, "name": "风隼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 5, "strength": 7, "constitution": 9, "intelligence": 3}, "experience": 0, "description": "速度极快的飞行焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 16, "attack": 30, "health": 231, "defense": 14, "critRate": 0.14, "stunRate": 0.07, "comboRate": 0.08, "dodgeRate": 0.08, "healBoost": 0.1, "critResist": 0.09, "stunResist": 0.1, "combatBoost": 0.09, "comboResist": 0.13, "counterRate": 0.12, "dodgeResist": 0.1, "vampireRate": 0.13, "counterResist": 0.09, "vampireResist": 0.11, "critDamageBoost": 0.11, "resistanceBoost": 0.12, "critDamageReduce": 0.08, "finalDamageBoost": 0.14, "finalDamageReduce": 0.07}}, {"id": 1771671550219.9656, "name": "云豹", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 3, "strength": 6, "constitution": 4, "intelligence": 8}, "experience": 0, "description": "敏捷的猎手", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 16, "attack": 26, "health": 208, "defense": 15, "critRate": 0.07, "stunRate": 0.13, "comboRate": 0.1, "dodgeRate": 0.13, "healBoost": 0.12, "critResist": 0.09, "stunResist": 0.14, "combatBoost": 0.13, "comboResist": 0.12, "counterRate": 0.11, "dodgeResist": 0.08, "vampireRate": 0.11, "counterResist": 0.13, "vampireResist": 0.1, "critDamageBoost": 0.14, "resistanceBoost": 0.1, "critDamageReduce": 0.12, "finalDamageBoost": 0.12, "finalDamageReduce": 0.08}}, {"id": 1771671550219.0532, "name": "冰狼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 8, "strength": 10, "constitution": 7, "intelligence": 9}, "experience": 0, "description": "冰原霸主", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 26, "attack": 31, "health": 323, "defense": 22, "critRate": 0.09, "stunRate": 0.1, "comboRate": 0.1, "dodgeRate": 0.16, "healBoost": 0.12, "critResist": 0.09, "stunResist": 0.09, "combatBoost": 0.11, "comboResist": 0.14, "counterRate": 0.16, "dodgeResist": 0.11, "vampireRate": 0.11, "counterResist": 0.13, "vampireResist": 0.08, "critDamageBoost": 0.14, "resistanceBoost": 0.1, "critDamageReduce": 0.14, "finalDamageBoost": 0.14, "finalDamageReduce": 0.11}}, {"id": 1771671550219.9016, "name": "冰狼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 6, "strength": 9, "constitution": 1, "intelligence": 6}, "experience": 0, "description": "冰原霸主", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 18, "attack": 38, "health": 307, "defense": 17, "critRate": 0.13, "stunRate": 0.16, "comboRate": 0.13, "dodgeRate": 0.11, "healBoost": 0.13, "critResist": 0.08, "stunResist": 0.1, "combatBoost": 0.1, "comboResist": 0.15, "counterRate": 0.15, "dodgeResist": 0.13, "vampireRate": 0.12, "counterResist": 0.14, "vampireResist": 0.14, "critDamageBoost": 0.11, "resistanceBoost": 0.15, "critDamageReduce": 0.09, "finalDamageBoost": 0.11, "finalDamageReduce": 0.14}}, {"id": 1771671550248.2969, "name": "玄龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 2, "strength": 3, "constitution": 5, "intelligence": 2}, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 17, "attack": 25, "health": 217, "defense": 14, "critRate": 0.12, "stunRate": 0.1, "comboRate": 0.09, "dodgeRate": 0.13, "healBoost": 0.11, "critResist": 0.08, "stunResist": 0.12, "combatBoost": 0.11, "comboResist": 0.09, "counterRate": 0.09, "dodgeResist": 0.12, "vampireRate": 0.11, "counterResist": 0.11, "vampireResist": 0.11, "critDamageBoost": 0.13, "resistanceBoost": 0.1, "critDamageReduce": 0.12, "finalDamageBoost": 0.1, "finalDamageReduce": 0.1}}, {"id": 1771671550387.0337, "name": "岩龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 7, "strength": 4, "constitution": 6, "intelligence": 9}, "experience": 0, "description": "坚不可摧的守护者", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 18, "attack": 33, "health": 315, "defense": 21, "critRate": 0.13, "stunRate": 0.14, "comboRate": 0.15, "dodgeRate": 0.09, "healBoost": 0.08, "critResist": 0.1, "stunResist": 0.11, "combatBoost": 0.08, "comboResist": 0.12, "counterRate": 0.13, "dodgeResist": 0.1, "vampireRate": 0.11, "counterResist": 0.15, "vampireResist": 0.16, "critDamageBoost": 0.13, "resistanceBoost": 0.13, "critDamageReduce": 0.13, "finalDamageBoost": 0.09, "finalDamageReduce": 0.11}}, {"id": 1771671550387.9053, "name": "火鼠", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 10, "strength": 4, "constitution": 10, "intelligence": 2}, "experience": 0, "description": "活泼的啮齿类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 12, "health": 115, "defense": 6, "critRate": 0.08, "stunRate": 0.09, "comboRate": 0.08, "dodgeRate": 0.09, "healBoost": 0.05, "critResist": 0.09, "stunResist": 0.05, "combatBoost": 0.1, "comboResist": 0.09, "counterRate": 0.07, "dodgeResist": 0.1, "vampireRate": 0.09, "counterResist": 0.09, "vampireResist": 0.09, "critDamageBoost": 0.09, "resistanceBoost": 0.1, "critDamageReduce": 0.07, "finalDamageBoost": 0.07, "finalDamageReduce": 0.1}}, {"id": 1771671550387.261, "name": "灵猫", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 5, "strength": 8, "constitution": 3, "intelligence": 4}, "experience": 0, "description": "敏捷的小型焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 6, "attack": 12, "health": 105, "defense": 6, "critRate": 0.08, "stunRate": 0.06, "comboRate": 0.07, "dodgeRate": 0.06, "healBoost": 0.06, "critResist": 0.1, "stunResist": 0.07, "combatBoost": 0.09, "comboResist": 0.07, "counterRate": 0.07, "dodgeResist": 0.06, "vampireRate": 0.05, "counterResist": 0.07, "vampireResist": 0.07, "critDamageBoost": 0.09, "resistanceBoost": 0.09, "critDamageReduce": 0.05, "finalDamageBoost": 0.07, "finalDamageReduce": 0.08}}, {"id": 1771671550387.1687, "name": "玄龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 9, "strength": 10, "constitution": 10, "intelligence": 4}, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 18, "attack": 27, "health": 239, "defense": 14, "critRate": 0.13, "stunRate": 0.11, "comboRate": 0.09, "dodgeRate": 0.11, "healBoost": 0.12, "critResist": 0.13, "stunResist": 0.08, "combatBoost": 0.08, "comboResist": 0.08, "counterRate": 0.12, "dodgeResist": 0.08, "vampireRate": 0.11, "counterResist": 0.1, "vampireResist": 0.14, "critDamageBoost": 0.12, "resistanceBoost": 0.13, "critDamageReduce": 0.1, "finalDamageBoost": 0.12, "finalDamageReduce": 0.08}}, {"id": 1771671550387.85, "name": "草兔", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 8, "constitution": 10, "intelligence": 3}, "experience": 0, "description": "温顺的兔类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 6, "attack": 12, "health": 108, "defense": 7, "critRate": 0.07, "stunRate": 0.07, "comboRate": 0.08, "dodgeRate": 0.06, "healBoost": 0.07, "critResist": 0.07, "stunResist": 0.09, "combatBoost": 0.05, "comboResist": 0.07, "counterRate": 0.05, "dodgeResist": 0.05, "vampireRate": 0.07, "counterResist": 0.07, "vampireResist": 0.07, "critDamageBoost": 0.06, "resistanceBoost": 0.08, "critDamageReduce": 0.06, "finalDamageBoost": 0.07, "finalDamageReduce": 0.06}}, {"id": 1771671550387.9182, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 6, "strength": 9, "constitution": 9, "intelligence": 1}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 15, "health": 110, "defense": 5, "critRate": 0.06, "stunRate": 0.07, "comboRate": 0.09, "dodgeRate": 0.08, "healBoost": 0.07, "critResist": 0.09, "stunResist": 0.09, "combatBoost": 0.06, "comboResist": 0.06, "counterRate": 0.09, "dodgeResist": 0.09, "vampireRate": 0.08, "counterResist": 0.07, "vampireResist": 0.07, "critDamageBoost": 0.05, "resistanceBoost": 0.05, "critDamageReduce": 0.08, "finalDamageBoost": 0.08, "finalDamageReduce": 0.09}}, {"id": 1771671550387.3625, "name": "火凤凰", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 9, "strength": 4, "constitution": 6, "intelligence": 7}, "experience": 0, "description": "浴火重生的永恒之鸟", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 24, "attack": 43, "health": 314, "defense": 19, "critRate": 0.15, "stunRate": 0.14, "comboRate": 0.14, "dodgeRate": 0.13, "healBoost": 0.1, "critResist": 0.16, "stunResist": 0.15, "combatBoost": 0.15, "comboResist": 0.09, "counterRate": 0.09, "dodgeResist": 0.16, "vampireRate": 0.1, "counterResist": 0.12, "vampireResist": 0.11, "critDamageBoost": 0.13, "resistanceBoost": 0.12, "critDamageReduce": 0.14, "finalDamageBoost": 0.15, "finalDamageReduce": 0.09}}, {"id": 1771671550387.9214, "name": "岩龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 5, "strength": 1, "constitution": 1, "intelligence": 6}, "experience": 0, "description": "坚不可摧的守护者", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 19, "attack": 38, "health": 303, "defense": 16, "critRate": 0.16, "stunRate": 0.14, "comboRate": 0.15, "dodgeRate": 0.14, "healBoost": 0.09, "critResist": 0.14, "stunResist": 0.16, "combatBoost": 0.1, "comboResist": 0.1, "counterRate": 0.09, "dodgeResist": 0.09, "vampireRate": 0.15, "counterResist": 0.15, "vampireResist": 0.15, "critDamageBoost": 0.09, "resistanceBoost": 0.09, "critDamageReduce": 0.13, "finalDamageBoost": 0.14, "finalDamageReduce": 0.1}}, {"id": 1771671550387.2554, "name": "云豹", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 3, "strength": 4, "constitution": 4, "intelligence": 8}, "experience": 0, "description": "敏捷的猎手", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 13, "attack": 28, "health": 237, "defense": 15, "critRate": 0.12, "stunRate": 0.12, "comboRate": 0.14, "dodgeRate": 0.1, "healBoost": 0.09, "critResist": 0.1, "stunResist": 0.13, "combatBoost": 0.1, "comboResist": 0.14, "counterRate": 0.1, "dodgeResist": 0.12, "vampireRate": 0.1, "counterResist": 0.12, "vampireResist": 0.08, "critDamageBoost": 0.08, "resistanceBoost": 0.08, "critDamageReduce": 0.11, "finalDamageBoost": 0.14, "finalDamageReduce": 0.11}}, {"id": 1771671550387.193, "name": "火鼠", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 1, "strength": 9, "constitution": 1, "intelligence": 4}, "experience": 0, "description": "活泼的啮齿类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 12, "health": 112, "defense": 7, "critRate": 0.05, "stunRate": 0.08, "comboRate": 0.06, "dodgeRate": 0.06, "healBoost": 0.06, "critResist": 0.07, "stunResist": 0.06, "combatBoost": 0.05, "comboResist": 0.07, "counterRate": 0.08, "dodgeResist": 0.07, "vampireRate": 0.08, "counterResist": 0.05, "vampireResist": 0.08, "critDamageBoost": 0.08, "resistanceBoost": 0.07, "critDamageReduce": 0.09, "finalDamageBoost": 0.07, "finalDamageReduce": 0.1}}, {"id": 1771671550387.5693, "name": "灵猫", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 5, "strength": 6, "constitution": 7, "intelligence": 1}, "experience": 0, "description": "敏捷的小型焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 13, "health": 113, "defense": 8, "critRate": 0.09, "stunRate": 0.09, "comboRate": 0.07, "dodgeRate": 0.09, "healBoost": 0.06, "critResist": 0.09, "stunResist": 0.07, "combatBoost": 0.07, "comboResist": 0.1, "counterRate": 0.06, "dodgeResist": 0.1, "vampireRate": 0.06, "counterResist": 0.07, "vampireResist": 0.05, "critDamageBoost": 0.09, "resistanceBoost": 0.07, "critDamageReduce": 0.07, "finalDamageBoost": 0.08, "finalDamageReduce": 0.1}}, {"id": 1771671550387.141, "name": "玄龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 8, "strength": 9, "constitution": 10, "intelligence": 7}, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 12, "attack": 27, "health": 224, "defense": 12, "critRate": 0.11, "stunRate": 0.13, "comboRate": 0.09, "dodgeRate": 0.14, "healBoost": 0.07, "critResist": 0.1, "stunResist": 0.13, "combatBoost": 0.13, "comboResist": 0.1, "counterRate": 0.13, "dodgeResist": 0.12, "vampireRate": 0.07, "counterResist": 0.14, "vampireResist": 0.08, "critDamageBoost": 0.08, "resistanceBoost": 0.1, "critDamageReduce": 0.08, "finalDamageBoost": 0.11, "finalDamageReduce": 0.13}}, {"id": 1771671550387.0647, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 1, "constitution": 5, "intelligence": 7}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 9, "attack": 10, "health": 114, "defense": 7, "critRate": 0.07, "stunRate": 0.08, "comboRate": 0.1, "dodgeRate": 0.09, "healBoost": 0.07, "critResist": 0.08, "stunResist": 0.06, "combatBoost": 0.06, "comboResist": 0.06, "counterRate": 0.07, "dodgeResist": 0.08, "vampireRate": 0.06, "counterResist": 0.07, "vampireResist": 0.06, "critDamageBoost": 0.08, "resistanceBoost": 0.07, "critDamageReduce": 0.05, "finalDamageBoost": 0.1, "finalDamageReduce": 0.06}}, {"id": 1771671550387.1443, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 5, "strength": 7, "constitution": 7, "intelligence": 4}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 13, "health": 113, "defense": 8, "critRate": 0.1, "stunRate": 0.1, "comboRate": 0.08, "dodgeRate": 0.08, "healBoost": 0.05, "critResist": 0.06, "stunResist": 0.05, "combatBoost": 0.06, "comboResist": 0.06, "counterRate": 0.07, "dodgeResist": 0.07, "vampireRate": 0.08, "counterResist": 0.1, "vampireResist": 0.09, "critDamageBoost": 0.1, "resistanceBoost": 0.1, "critDamageReduce": 0.06, "finalDamageBoost": 0.07, "finalDamageReduce": 0.05}}, {"id": 1771671550387.5322, "name": "螭吻", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "celestial", "quality": {"agility": 8, "strength": 6, "constitution": 5, "intelligence": 8}, "experience": 0, "description": "龙之九子，形似鱼，能吞火，常立于屋脊", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 33, "attack": 51, "health": 409, "defense": 29, "critRate": 0.15, "stunRate": 0.11, "comboRate": 0.15, "dodgeRate": 0.12, "healBoost": 0.18, "critResist": 0.17, "stunResist": 0.15, "combatBoost": 0.14, "comboResist": 0.17, "counterRate": 0.18, "dodgeResist": 0.17, "vampireRate": 0.18, "counterResist": 0.16, "vampireResist": 0.14, "critDamageBoost": 0.15, "resistanceBoost": 0.1, "critDamageReduce": 0.12, "finalDamageBoost": 0.18, "finalDamageReduce": 0.16}}, {"id": 1771671550387.017, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 9, "strength": 3, "constitution": 8, "intelligence": 3}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 15, "health": 100, "defense": 8, "critRate": 0.1, "stunRate": 0.06, "comboRate": 0.09, "dodgeRate": 0.09, "healBoost": 0.07, "critResist": 0.1, "stunResist": 0.06, "combatBoost": 0.1, "comboResist": 0.05, "counterRate": 0.08, "dodgeResist": 0.07, "vampireRate": 0.05, "counterResist": 0.1, "vampireResist": 0.09, "critDamageBoost": 0.07, "resistanceBoost": 0.08, "critDamageReduce": 0.07, "finalDamageBoost": 0.09, "finalDamageReduce": 0.07}}, {"id": 1771671550387.9111, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 2, "constitution": 3, "intelligence": 7}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 15, "health": 101, "defense": 8, "critRate": 0.07, "stunRate": 0.07, "comboRate": 0.08, "dodgeRate": 0.06, "healBoost": 0.08, "critResist": 0.07, "stunResist": 0.05, "combatBoost": 0.06, "comboResist": 0.1, "counterRate": 0.08, "dodgeResist": 0.08, "vampireRate": 0.09, "counterResist": 0.05, "vampireResist": 0.08, "critDamageBoost": 0.09, "resistanceBoost": 0.1, "critDamageReduce": 0.1, "finalDamageBoost": 0.08, "finalDamageReduce": 0.08}}, {"id": 1771671550387.4773, "name": "火鼠", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 3, "constitution": 10, "intelligence": 5}, "experience": 0, "description": "活泼的啮齿类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 10, "health": 108, "defense": 6, "critRate": 0.08, "stunRate": 0.07, "comboRate": 0.06, "dodgeRate": 0.07, "healBoost": 0.06, "critResist": 0.09, "stunResist": 0.06, "combatBoost": 0.05, "comboResist": 0.09, "counterRate": 0.06, "dodgeResist": 0.07, "vampireRate": 0.07, "counterResist": 0.07, "vampireResist": 0.08, "critDamageBoost": 0.06, "resistanceBoost": 0.07, "critDamageReduce": 0.06, "finalDamageBoost": 0.08, "finalDamageReduce": 0.07}}, {"id": 1771671550387.2922, "name": "冰狼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 10, "strength": 1, "constitution": 6, "intelligence": 7}, "experience": 0, "description": "冰原霸主", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 26, "attack": 44, "health": 328, "defense": 22, "critRate": 0.11, "stunRate": 0.14, "comboRate": 0.14, "dodgeRate": 0.11, "healBoost": 0.13, "critResist": 0.16, "stunResist": 0.15, "combatBoost": 0.13, "comboResist": 0.13, "counterRate": 0.08, "dodgeResist": 0.11, "vampireRate": 0.15, "counterResist": 0.16, "vampireResist": 0.15, "critDamageBoost": 0.13, "resistanceBoost": 0.1, "critDamageReduce": 0.11, "finalDamageBoost": 0.15, "finalDamageReduce": 0.15}}, {"id": 1771671550387.8171, "name": "玄龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 10, "strength": 5, "constitution": 7, "intelligence": 1}, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 14, "attack": 22, "health": 221, "defense": 15, "critRate": 0.08, "stunRate": 0.08, "comboRate": 0.13, "dodgeRate": 0.1, "healBoost": 0.11, "critResist": 0.09, "stunResist": 0.07, "combatBoost": 0.1, "comboResist": 0.11, "counterRate": 0.1, "dodgeResist": 0.12, "vampireRate": 0.08, "counterResist": 0.09, "vampireResist": 0.1, "critDamageBoost": 0.11, "resistanceBoost": 0.09, "critDamageReduce": 0.13, "finalDamageBoost": 0.14, "finalDamageReduce": 0.12}}, {"id": 1771671550387.6243, "name": "火鼠", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 5, "strength": 8, "constitution": 10, "intelligence": 6}, "experience": 0, "description": "活泼的啮齿类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 14, "health": 118, "defense": 8, "critRate": 0.1, "stunRate": 0.1, "comboRate": 0.06, "dodgeRate": 0.08, "healBoost": 0.05, "critResist": 0.06, "stunResist": 0.06, "combatBoost": 0.05, "comboResist": 0.07, "counterRate": 0.07, "dodgeResist": 0.09, "vampireRate": 0.08, "counterResist": 0.1, "vampireResist": 0.09, "critDamageBoost": 0.06, "resistanceBoost": 0.07, "critDamageReduce": 0.07, "finalDamageBoost": 0.07, "finalDamageReduce": 0.09}}, {"id": 1771671550387.2207, "name": "岩龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 1, "strength": 3, "constitution": 5, "intelligence": 4}, "experience": 0, "description": "坚不可摧的守护者", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 26, "attack": 39, "health": 317, "defense": 19, "critRate": 0.09, "stunRate": 0.1, "comboRate": 0.16, "dodgeRate": 0.12, "healBoost": 0.11, "critResist": 0.11, "stunResist": 0.09, "combatBoost": 0.12, "comboResist": 0.09, "counterRate": 0.08, "dodgeResist": 0.13, "vampireRate": 0.16, "counterResist": 0.14, "vampireResist": 0.13, "critDamageBoost": 0.14, "resistanceBoost": 0.14, "critDamageReduce": 0.09, "finalDamageBoost": 0.11, "finalDamageReduce": 0.13}}, {"id": 1771671550387.3772, "name": "云豹", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 7, "strength": 2, "constitution": 8, "intelligence": 3}, "experience": 0, "description": "敏捷的猎手", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 12, "attack": 22, "health": 236, "defense": 14, "critRate": 0.11, "stunRate": 0.07, "comboRate": 0.07, "dodgeRate": 0.14, "healBoost": 0.12, "critResist": 0.07, "stunResist": 0.1, "combatBoost": 0.14, "comboResist": 0.1, "counterRate": 0.09, "dodgeResist": 0.13, "vampireRate": 0.08, "counterResist": 0.09, "vampireResist": 0.11, "critDamageBoost": 0.07, "resistanceBoost": 0.11, "critDamageReduce": 0.13, "finalDamageBoost": 0.12, "finalDamageReduce": 0.11}}, {"id": 1771671550387.2954, "name": "负屃", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "celestial", "quality": {"agility": 9, "strength": 3, "constitution": 2, "intelligence": 5}, "experience": 0, "description": "龙之八子，形似龙，雅好诗文，常盘于碑顶", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 36, "attack": 59, "health": 427, "defense": 22, "critRate": 0.18, "stunRate": 0.1, "comboRate": 0.18, "dodgeRate": 0.11, "healBoost": 0.11, "critResist": 0.14, "stunResist": 0.12, "combatBoost": 0.14, "comboResist": 0.11, "counterRate": 0.11, "dodgeResist": 0.15, "vampireRate": 0.18, "counterResist": 0.11, "vampireResist": 0.13, "critDamageBoost": 0.15, "resistanceBoost": 0.18, "critDamageReduce": 0.11, "finalDamageBoost": 0.12, "finalDamageReduce": 0.16}}, {"id": 1771671550387.5205, "name": "云豹", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 6, "strength": 1, "constitution": 2, "intelligence": 1}, "experience": 0, "description": "敏捷的猎手", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 18, "attack": 25, "health": 216, "defense": 12, "critRate": 0.09, "stunRate": 0.11, "comboRate": 0.09, "dodgeRate": 0.12, "healBoost": 0.11, "critResist": 0.07, "stunResist": 0.13, "combatBoost": 0.12, "comboResist": 0.11, "counterRate": 0.12, "dodgeResist": 0.11, "vampireRate": 0.13, "counterResist": 0.08, "vampireResist": 0.11, "critDamageBoost": 0.09, "resistanceBoost": 0.12, "critDamageReduce": 0.1, "finalDamageBoost": 0.11, "finalDamageReduce": 0.12}}, {"id": 1771671550387.4868, "name": "草兔", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 9, "strength": 1, "constitution": 6, "intelligence": 10}, "experience": 0, "description": "温顺的兔类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 9, "attack": 15, "health": 116, "defense": 6, "critRate": 0.1, "stunRate": 0.07, "comboRate": 0.1, "dodgeRate": 0.07, "healBoost": 0.09, "critResist": 0.06, "stunResist": 0.07, "combatBoost": 0.07, "comboResist": 0.06, "counterRate": 0.09, "dodgeResist": 0.08, "vampireRate": 0.07, "counterResist": 0.08, "vampireResist": 0.06, "critDamageBoost": 0.07, "resistanceBoost": 0.08, "critDamageReduce": 0.06, "finalDamageBoost": 0.09, "finalDamageReduce": 0.07}}, {"id": 1771671550387.4758, "name": "云豹", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 9, "strength": 10, "constitution": 1, "intelligence": 1}, "experience": 0, "description": "敏捷的猎手", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 15, "attack": 22, "health": 217, "defense": 14, "critRate": 0.1, "stunRate": 0.08, "comboRate": 0.13, "dodgeRate": 0.14, "healBoost": 0.14, "critResist": 0.1, "stunResist": 0.09, "combatBoost": 0.09, "comboResist": 0.1, "counterRate": 0.07, "dodgeResist": 0.1, "vampireRate": 0.07, "counterResist": 0.07, "vampireResist": 0.11, "critDamageBoost": 0.08, "resistanceBoost": 0.07, "critDamageReduce": 0.08, "finalDamageBoost": 0.11, "finalDamageReduce": 0.08}}, {"id": 1771671550387.8193, "name": "灵猫", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 7, "constitution": 3, "intelligence": 9}, "experience": 0, "description": "敏捷的小型焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 6, "attack": 15, "health": 105, "defense": 8, "critRate": 0.09, "stunRate": 0.09, "comboRate": 0.1, "dodgeRate": 0.09, "healBoost": 0.07, "critResist": 0.09, "stunResist": 0.09, "combatBoost": 0.07, "comboResist": 0.07, "counterRate": 0.09, "dodgeResist": 0.09, "vampireRate": 0.05, "counterResist": 0.09, "vampireResist": 0.09, "critDamageBoost": 0.07, "resistanceBoost": 0.07, "critDamageReduce": 0.08, "finalDamageBoost": 0.05, "finalDamageReduce": 0.08}}, {"id": 1771671550387.5312, "name": "玄龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 1, "strength": 1, "constitution": 8, "intelligence": 4}, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 14, "attack": 21, "health": 219, "defense": 15, "critRate": 0.12, "stunRate": 0.08, "comboRate": 0.13, "dodgeRate": 0.1, "healBoost": 0.08, "critResist": 0.13, "stunResist": 0.13, "combatBoost": 0.12, "comboResist": 0.1, "counterRate": 0.1, "dodgeResist": 0.1, "vampireRate": 0.11, "counterResist": 0.13, "vampireResist": 0.08, "critDamageBoost": 0.12, "resistanceBoost": 0.09, "critDamageReduce": 0.11, "finalDamageBoost": 0.1, "finalDamageReduce": 0.1}}, {"id": 1771671550387.9797, "name": "火鼠", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 3, "strength": 3, "constitution": 3, "intelligence": 6}, "experience": 0, "description": "活泼的啮齿类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 9, "attack": 11, "health": 107, "defense": 7, "critRate": 0.08, "stunRate": 0.1, "comboRate": 0.07, "dodgeRate": 0.07, "healBoost": 0.08, "critResist": 0.05, "stunResist": 0.08, "combatBoost": 0.07, "comboResist": 0.06, "counterRate": 0.05, "dodgeResist": 0.06, "vampireRate": 0.1, "counterResist": 0.09, "vampireResist": 0.09, "critDamageBoost": 0.06, "resistanceBoost": 0.07, "critDamageReduce": 0.1, "finalDamageBoost": 0.08, "finalDamageReduce": 0.07}}, {"id": 1771671550387.976, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 10, "strength": 3, "constitution": 7, "intelligence": 10}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 13, "health": 119, "defense": 8, "critRate": 0.09, "stunRate": 0.06, "comboRate": 0.09, "dodgeRate": 0.08, "healBoost": 0.09, "critResist": 0.07, "stunResist": 0.07, "combatBoost": 0.09, "comboResist": 0.08, "counterRate": 0.07, "dodgeResist": 0.06, "vampireRate": 0.08, "counterResist": 0.08, "vampireResist": 0.06, "critDamageBoost": 0.07, "resistanceBoost": 0.07, "critDamageReduce": 0.07, "finalDamageBoost": 0.06, "finalDamageReduce": 0.07}}, {"id": 1771671550387.2988, "name": "雷鹰", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 9, "strength": 2, "constitution": 2, "intelligence": 1}, "experience": 0, "description": "雷电的猛禽", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 25, "attack": 37, "health": 327, "defense": 17, "critRate": 0.08, "stunRate": 0.08, "comboRate": 0.15, "dodgeRate": 0.11, "healBoost": 0.12, "critResist": 0.14, "stunResist": 0.09, "combatBoost": 0.13, "comboResist": 0.15, "counterRate": 0.09, "dodgeResist": 0.08, "vampireRate": 0.15, "counterResist": 0.13, "vampireResist": 0.09, "critDamageBoost": 0.11, "resistanceBoost": 0.15, "critDamageReduce": 0.08, "finalDamageBoost": 0.1, "finalDamageReduce": 0.11}}, {"id": 1771671550387.8296, "name": "草兔", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 2, "strength": 4, "constitution": 3, "intelligence": 6}, "experience": 0, "description": "温顺的兔类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 12, "health": 105, "defense": 6, "critRate": 0.1, "stunRate": 0.06, "comboRate": 0.09, "dodgeRate": 0.08, "healBoost": 0.08, "critResist": 0.06, "stunResist": 0.1, "combatBoost": 0.06, "comboResist": 0.07, "counterRate": 0.08, "dodgeResist": 0.05, "vampireRate": 0.09, "counterResist": 0.1, "vampireResist": 0.06, "critDamageBoost": 0.08, "resistanceBoost": 0.05, "critDamageReduce": 0.06, "finalDamageBoost": 0.05, "finalDamageReduce": 0.06}}, {"id": 1771671550387.867, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 3, "strength": 2, "constitution": 5, "intelligence": 5}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 9, "attack": 15, "health": 117, "defense": 6, "critRate": 0.09, "stunRate": 0.07, "comboRate": 0.07, "dodgeRate": 0.07, "healBoost": 0.05, "critResist": 0.1, "stunResist": 0.07, "combatBoost": 0.05, "comboResist": 0.09, "counterRate": 0.08, "dodgeResist": 0.06, "vampireRate": 0.06, "counterResist": 0.05, "vampireResist": 0.08, "critDamageBoost": 0.07, "resistanceBoost": 0.09, "critDamageReduce": 0.07, "finalDamageBoost": 0.06, "finalDamageReduce": 0.08}}, {"id": 1771671550387.666, "name": "草兔", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 3, "constitution": 5, "intelligence": 4}, "experience": 0, "description": "温顺的兔类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 12, "health": 103, "defense": 8, "critRate": 0.05, "stunRate": 0.09, "comboRate": 0.1, "dodgeRate": 0.07, "healBoost": 0.07, "critResist": 0.06, "stunResist": 0.06, "combatBoost": 0.08, "comboResist": 0.09, "counterRate": 0.08, "dodgeResist": 0.07, "vampireRate": 0.06, "counterResist": 0.07, "vampireResist": 0.08, "critDamageBoost": 0.09, "resistanceBoost": 0.08, "critDamageReduce": 0.1, "finalDamageBoost": 0.07, "finalDamageReduce": 0.1}}, {"id": 1771671550387.2104, "name": "地甲", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 8, "strength": 4, "constitution": 8, "intelligence": 1}, "experience": 0, "description": "坚固的大地守护者", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 14, "attack": 28, "health": 230, "defense": 13, "critRate": 0.13, "stunRate": 0.12, "comboRate": 0.09, "dodgeRate": 0.11, "healBoost": 0.12, "critResist": 0.08, "stunResist": 0.1, "combatBoost": 0.11, "comboResist": 0.12, "counterRate": 0.08, "dodgeResist": 0.11, "vampireRate": 0.08, "counterResist": 0.11, "vampireResist": 0.07, "critDamageBoost": 0.12, "resistanceBoost": 0.07, "critDamageReduce": 0.08, "finalDamageBoost": 0.13, "finalDamageReduce": 0.1}}, {"id": 1771671550387.0518, "name": "星宝焰器·道", "slot": "artifact", "type": "artifact", "level": 13, "stats": {"attack": 1, "critRate": 0.63, "comboRate": 0.71}, "quality": "uncommon", "category": "equipment", "equipType": "artifact", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 13}, {"id": 1771671550387.3079, "name": "云雾裤子", "slot": "legs", "type": "legs", "level": 6, "stats": {"speed": 14, "defense": 10, "dodgeRate": 0.14}, "quality": "common", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 6}, {"id": 1771671550387.938, "name": "玄圣焰心链", "slot": "necklace", "type": "necklace", "level": 7, "stats": {"health": 123, "healBoost": 0.31, "spiritRate": 0.24}, "quality": "common", "category": "equipment", "equipType": "necklace", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 7}, {"id": 1771671550387.8188, "name": "赤金手套·天", "slot": "hands", "type": "hands", "level": 4, "stats": {"attack": 18, "critRate": 0.12, "comboRate": 0.2}, "quality": "rare", "category": "equipment", "equipType": "hands", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 4}, {"id": 1771671550387.6348, "name": "紫系腰带·道", "slot": "belt", "type": "belt", "level": 5, "stats": {"health": 77, "defense": 9, "combatBoost": 0.18}, "quality": "uncommon", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 5}, {"id": 1771671550387.749, "name": "天珠焰心链", "slot": "necklace", "type": "necklace", "level": 6, "stats": {"health": 127, "healBoost": 0.2, "spiritRate": 0.2}, "quality": "common", "category": "equipment", "equipType": "necklace", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 6}, {"id": 1771671550387.9387, "name": "草兔", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 8, "strength": 7, "constitution": 3, "intelligence": 9}, "experience": 0, "description": "温顺的兔类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 13, "health": 114, "defense": 7, "critRate": 0.07, "stunRate": 0.08, "comboRate": 0.07, "dodgeRate": 0.08, "healBoost": 0.08, "critResist": 0.06, "stunResist": 0.07, "combatBoost": 0.08, "comboResist": 0.06, "counterRate": 0.09, "dodgeResist": 0.09, "vampireRate": 0.1, "counterResist": 0.09, "vampireResist": 0.1, "critDamageBoost": 0.09, "resistanceBoost": 0.09, "critDamageReduce": 0.08, "finalDamageBoost": 0.05, "finalDamageReduce": 0.09}}, {"id": 1771671550387.961, "name": "火凤凰", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 6, "strength": 7, "constitution": 4, "intelligence": 1}, "experience": 0, "description": "浴火重生的永恒之鸟", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 23, "attack": 36, "health": 358, "defense": 18, "critRate": 0.12, "stunRate": 0.13, "comboRate": 0.12, "dodgeRate": 0.09, "healBoost": 0.14, "critResist": 0.14, "stunResist": 0.12, "combatBoost": 0.14, "comboResist": 0.1, "counterRate": 0.13, "dodgeResist": 0.12, "vampireRate": 0.11, "counterResist": 0.1, "vampireResist": 0.09, "critDamageBoost": 0.1, "resistanceBoost": 0.13, "critDamageReduce": 0.11, "finalDamageBoost": 0.1, "finalDamageReduce": 0.14}}, {"id": 1771671550387.9258, "name": "天绝护腕·天", "slot": "wrist", "type": "wrist", "level": 7, "stats": {"defense": 14, "counterRate": 0.25, "vampireRate": 0.19}, "quality": "rare", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 7}, {"id": 1771671550387.3115, "name": "青莲鞋子·圣", "slot": "feet", "type": "feet", "level": 5, "stats": {"speed": 32, "defense": 30, "dodgeRate": 0.37}, "quality": "legendary", "category": "equipment", "equipType": "feet", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 2.5, "maxStatMod": 3.5}, "requiredRealm": 5}, {"id": 1771671550387.321, "name": "地甲", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 1, "strength": 6, "constitution": 4, "intelligence": 6}, "experience": 0, "description": "坚固的大地守护者", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 15, "attack": 29, "health": 211, "defense": 14, "critRate": 0.13, "stunRate": 0.11, "comboRate": 0.11, "dodgeRate": 0.08, "healBoost": 0.1, "critResist": 0.11, "stunResist": 0.12, "combatBoost": 0.13, "comboResist": 0.1, "counterRate": 0.14, "dodgeResist": 0.08, "vampireRate": 0.09, "counterResist": 0.12, "vampireResist": 0.09, "critDamageBoost": 0.11, "resistanceBoost": 0.11, "critDamageReduce": 0.09, "finalDamageBoost": 0.08, "finalDamageReduce": 0.12}}, {"id": 1771671550387.189, "name": "赤命符文戒1·道", "slot": "ring1", "type": "ring1", "level": 12, "stats": {"attack": 22, "critDamageBoost": 0.37, "finalDamageBoost": 0.21}, "quality": "uncommon", "category": "equipment", "equipType": "ring1", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 12}, {"id": 1771671550387.9033, "name": "赤炎焰杖", "slot": "weapon", "type": "weapon", "level": 4, "stats": {"attack": 15, "critRate": 0.14, "critDamageBoost": 0.26}, "quality": "common", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 4}, {"id": 1771671550387.3376, "name": "青系腰带·道", "slot": "belt", "type": "belt", "level": 7, "stats": {"health": 130, "defense": 10, "combatBoost": 0.16}, "quality": "uncommon", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 7}, {"id": 1771671550387.9429, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 8, "constitution": 5, "intelligence": 7}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 12, "health": 114, "defense": 7, "critRate": 0.1, "stunRate": 0.08, "comboRate": 0.07, "dodgeRate": 0.08, "healBoost": 0.08, "critResist": 0.05, "stunResist": 0.05, "combatBoost": 0.08, "comboResist": 0.06, "counterRate": 0.08, "dodgeResist": 0.07, "vampireRate": 0.05, "counterResist": 0.08, "vampireResist": 0.09, "critDamageBoost": 0.09, "resistanceBoost": 0.07, "critDamageReduce": 0.05, "finalDamageBoost": 0.07, "finalDamageReduce": 0.07}}, {"id": 1771671550387.2876, "name": "玄命符文戒1·道", "slot": "ring1", "type": "ring1", "level": 8, "stats": {"attack": 18, "critDamageBoost": 0.24, "finalDamageBoost": 0.19}, "quality": "uncommon", "category": "equipment", "equipType": "ring1", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 8}, {"id": 1771671550387.1743, "name": "天珠焰心链", "slot": "necklace", "type": "necklace", "level": 7, "stats": {"health": 142, "healBoost": 0.28, "spiritRate": 0.28}, "quality": "common", "category": "equipment", "equipType": "necklace", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 7}, {"id": 1771671550387.9436, "name": "火鼠", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 6, "constitution": 8, "intelligence": 8}, "experience": 0, "description": "活泼的啮齿类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 14, "health": 108, "defense": 5, "critRate": 0.09, "stunRate": 0.09, "comboRate": 0.08, "dodgeRate": 0.09, "healBoost": 0.06, "critResist": 0.06, "stunResist": 0.09, "combatBoost": 0.09, "comboResist": 0.08, "counterRate": 0.09, "dodgeResist": 0.06, "vampireRate": 0.09, "counterResist": 0.1, "vampireResist": 0.07, "critDamageBoost": 0.08, "resistanceBoost": 0.07, "critDamageReduce": 0.06, "finalDamageBoost": 0.07, "finalDamageReduce": 0.06}}, {"id": 1771671550387.584, "name": "赤铜护腕·道", "slot": "wrist", "type": "wrist", "level": 8, "stats": {"defense": 10, "counterRate": 0.18, "vampireRate": 0.15}, "quality": "uncommon", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 8}, {"id": 1771671550387.1716, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 4, "strength": 10, "constitution": 9, "intelligence": 1}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 9, "attack": 12, "health": 118, "defense": 7, "critRate": 0.08, "stunRate": 0.08, "comboRate": 0.07, "dodgeRate": 0.05, "healBoost": 0.08, "critResist": 0.07, "stunResist": 0.09, "combatBoost": 0.1, "comboResist": 0.06, "counterRate": 0.07, "dodgeResist": 0.1, "vampireRate": 0.1, "counterResist": 0.09, "vampireResist": 0.09, "critDamageBoost": 0.06, "resistanceBoost": 0.1, "critDamageReduce": 0.07, "finalDamageBoost": 0.09, "finalDamageReduce": 0.07}}, {"id": 1771671550387.1511, "name": "青龙衣服", "slot": "body", "type": "body", "level": 4, "stats": {"health": 152, "defense": 18, "finalDamageReduce": 0.1}, "quality": "common", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 4}, {"id": 1771671550387.5928, "name": "赤道符文戒2", "slot": "ring2", "type": "ring2", "level": 11, "stats": {"defense": 11, "resistanceBoost": 0.11, "critDamageReduce": 0.37}, "quality": "common", "category": "equipment", "equipType": "ring2", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 11}, {"id": 1771671550387.1677, "name": "风隼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 7, "strength": 5, "constitution": 9, "intelligence": 7}, "experience": 0, "description": "速度极快的飞行焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 17, "attack": 22, "health": 220, "defense": 14, "critRate": 0.1, "stunRate": 0.12, "comboRate": 0.07, "dodgeRate": 0.1, "healBoost": 0.1, "critResist": 0.07, "stunResist": 0.1, "combatBoost": 0.1, "comboResist": 0.08, "counterRate": 0.08, "dodgeResist": 0.14, "vampireRate": 0.11, "counterResist": 0.14, "vampireResist": 0.07, "critDamageBoost": 0.11, "resistanceBoost": 0.13, "critDamageReduce": 0.1, "finalDamageBoost": 0.12, "finalDamageReduce": 0.14}}, {"id": 1771671550387.946, "name": "玄龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 5, "strength": 7, "constitution": 6, "intelligence": 5}, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 13, "attack": 28, "health": 214, "defense": 10, "critRate": 0.12, "stunRate": 0.1, "comboRate": 0.11, "dodgeRate": 0.13, "healBoost": 0.13, "critResist": 0.13, "stunResist": 0.14, "combatBoost": 0.07, "comboResist": 0.13, "counterRate": 0.1, "dodgeResist": 0.13, "vampireRate": 0.11, "counterResist": 0.09, "vampireResist": 0.09, "critDamageBoost": 0.14, "resistanceBoost": 0.14, "critDamageReduce": 0.12, "finalDamageBoost": 0.13, "finalDamageReduce": 0.08}}, {"id": 1771671550387.812, "name": "赤炎焰杖·天", "slot": "weapon", "type": "weapon", "level": 12, "stats": {"attack": 46, "critRate": 0.17, "critDamageBoost": 0.58}, "quality": "rare", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 12}, {"id": 1771671550387.6099, "name": "星光裤子", "slot": "legs", "type": "legs", "level": 13, "stats": {"speed": 16, "defense": 16, "dodgeRate": 0.16}, "quality": "common", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 13}, {"id": 1771671550387.5217, "name": "玄铁护腕", "slot": "wrist", "type": "wrist", "level": 4, "stats": {"defense": 9, "counterRate": 0.13, "vampireRate": 0.11}, "quality": "common", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 4}, {"id": 1771671550387.9197, "name": "紫电裤子", "slot": "legs", "type": "legs", "level": 9, "stats": {"speed": 17, "defense": 20, "dodgeRate": 0.14}, "quality": "common", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 9}, {"id": 1771671550387.6511, "name": "星道符文戒2·道", "slot": "ring2", "type": "ring2", "level": 7, "stats": {"defense": 11, "resistanceBoost": 0.17, "critDamageReduce": 0.32}, "quality": "uncommon", "category": "equipment", "equipType": "ring2", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 7}, {"id": 1771671550387.1348, "name": "星宝焰器", "slot": "artifact", "type": "artifact", "level": 8, "stats": {"attack": 0, "critRate": 0.37, "comboRate": 0.52}, "quality": "common", "category": "equipment", "equipType": "artifact", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 8}, {"id": 1771671550387.075, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 9, "strength": 10, "constitution": 4, "intelligence": 9}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 15, "health": 110, "defense": 7, "critRate": 0.05, "stunRate": 0.08, "comboRate": 0.08, "dodgeRate": 0.1, "healBoost": 0.08, "critResist": 0.06, "stunResist": 0.08, "combatBoost": 0.07, "comboResist": 0.07, "counterRate": 0.09, "dodgeResist": 0.08, "vampireRate": 0.1, "counterResist": 0.06, "vampireResist": 0.06, "critDamageBoost": 0.09, "resistanceBoost": 0.06, "critDamageReduce": 0.07, "finalDamageBoost": 0.08, "finalDamageReduce": 0.08}}, {"id": 1771671550387.6975, "name": "风隼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 5, "strength": 10, "constitution": 9, "intelligence": 8}, "experience": 0, "description": "速度极快的飞行焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 12, "attack": 22, "health": 214, "defense": 15, "critRate": 0.09, "stunRate": 0.1, "comboRate": 0.08, "dodgeRate": 0.13, "healBoost": 0.11, "critResist": 0.07, "stunResist": 0.08, "combatBoost": 0.13, "comboResist": 0.14, "counterRate": 0.1, "dodgeResist": 0.08, "vampireRate": 0.12, "counterResist": 0.12, "vampireResist": 0.09, "critDamageBoost": 0.13, "resistanceBoost": 0.07, "critDamageReduce": 0.09, "finalDamageBoost": 0.14, "finalDamageReduce": 0.1}}, {"id": 1771671550387.5603, "name": "冰狼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 6, "strength": 6, "constitution": 1, "intelligence": 1}, "experience": 0, "description": "冰原霸主", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 20, "attack": 32, "health": 348, "defense": 21, "critRate": 0.09, "stunRate": 0.12, "comboRate": 0.15, "dodgeRate": 0.16, "healBoost": 0.1, "critResist": 0.12, "stunResist": 0.13, "combatBoost": 0.15, "comboResist": 0.11, "counterRate": 0.12, "dodgeResist": 0.13, "vampireRate": 0.1, "counterResist": 0.12, "vampireResist": 0.11, "critDamageBoost": 0.09, "resistanceBoost": 0.08, "critDamageReduce": 0.14, "finalDamageBoost": 0.14, "finalDamageReduce": 0.09}}, {"id": 1771671550387.123, "name": "灵猫", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 2, "constitution": 9, "intelligence": 5}, "experience": 0, "description": "敏捷的小型焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 6, "attack": 13, "health": 101, "defense": 5, "critRate": 0.06, "stunRate": 0.07, "comboRate": 0.05, "dodgeRate": 0.06, "healBoost": 0.08, "critResist": 0.08, "stunResist": 0.07, "combatBoost": 0.07, "comboResist": 0.05, "counterRate": 0.09, "dodgeResist": 0.1, "vampireRate": 0.06, "counterResist": 0.05, "vampireResist": 0.06, "critDamageBoost": 0.06, "resistanceBoost": 0.1, "critDamageReduce": 0.09, "finalDamageBoost": 0.06, "finalDamageReduce": 0.06}}, {"id": 1771671550387.0647, "name": "天罡裤子·仙", "slot": "legs", "type": "legs", "level": 8, "stats": {"speed": 32, "defense": 35, "dodgeRate": 0.22}, "quality": "epic", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 8}, {"id": 1771671550387.7336, "name": "灵猫", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 8, "strength": 2, "constitution": 3, "intelligence": 9}, "experience": 0, "description": "敏捷的小型焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 11, "health": 103, "defense": 6, "critRate": 0.06, "stunRate": 0.1, "comboRate": 0.1, "dodgeRate": 0.05, "healBoost": 0.08, "critResist": 0.06, "stunResist": 0.09, "combatBoost": 0.08, "comboResist": 0.08, "counterRate": 0.09, "dodgeResist": 0.09, "vampireRate": 0.06, "counterResist": 0.08, "vampireResist": 0.07, "critDamageBoost": 0.06, "resistanceBoost": 0.09, "critDamageReduce": 0.08, "finalDamageBoost": 0.06, "finalDamageReduce": 0.06}}, {"id": 1771671464433.3562, "name": "云甲肩甲·道", "slot": "shoulder", "type": "shoulder", "level": 3, "stats": {"health": 121, "defense": 13, "counterRate": 0.09}, "quality": "uncommon", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 3}, {"id": 1771671531719.224, "name": "天行鞋子·仙", "slot": "feet", "type": "feet", "level": 12, "stats": {"speed": 51, "defense": 19, "dodgeRate": 0.25}, "quality": "epic", "category": "equipment", "equipType": "feet", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 12}, {"id": 1771671542604.0227, "name": "玄系腰带", "slot": "belt", "type": "belt", "level": 10, "stats": {"health": 89, "defense": 12, "combatBoost": 0.19}, "quality": "common", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 10}, {"id": 1771671550166.5647, "name": "赤铜护腕", "slot": "wrist", "type": "wrist", "level": 3, "stats": {"defense": 5, "counterRate": 0.09, "vampireRate": 0.09}, "quality": "common", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 3}, {"id": 1771671550219.6743, "name": "混元衣服", "slot": "body", "type": "body", "level": 4, "stats": {"health": 145, "defense": 20, "finalDamageReduce": 0.08}, "quality": "common", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 4}, {"id": 1771671550219.7996, "name": "天护肩甲·道", "slot": "shoulder", "type": "shoulder", "level": 6, "stats": {"health": 135, "defense": 12, "counterRate": 0.11}, "quality": "uncommon", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 6}, {"id": 1771671550219.5544, "name": "幽岚肩甲·道", "slot": "shoulder", "type": "shoulder", "level": 7, "stats": {"health": 88, "defense": 14, "counterRate": 0.14}, "quality": "uncommon", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 7}, {"id": 1771671550387.261, "name": "混沌焰杖·道", "slot": "weapon", "type": "weapon", "level": 12, "stats": {"attack": 44, "critRate": 0.24, "critDamageBoost": 0.48}, "quality": "uncommon", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 12}, {"id": 1771671550387.607, "name": "九天焰杖·仙", "slot": "weapon", "type": "weapon", "level": 5, "stats": {"attack": 33, "critRate": 0.16, "critDamageBoost": 0.34}, "quality": "epic", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 5}, {"id": 1771671550219.0278, "name": "紫晶手套·道", "slot": "hands", "type": "hands", "level": 13, "stats": {"attack": 22, "critRate": 0.08, "comboRate": 0.23}, "quality": "uncommon", "category": "equipment", "equipType": "hands", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 13}, {"id": 1771671550219.7185, "name": "幽系腰带·道", "slot": "belt", "type": "belt", "level": 9, "stats": {"health": 176, "defense": 18, "combatBoost": 0.17}, "quality": "uncommon", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 9}, {"id": 1771671550387.6062, "name": "云道符文戒2·天", "slot": "ring2", "type": "ring2", "level": 6, "stats": {"defense": 14, "resistanceBoost": 0.17, "critDamageReduce": 0.31}, "quality": "rare", "category": "equipment", "equipType": "ring2", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 6}, {"id": 1771671550387.8403, "name": "幽宝焰器", "slot": "artifact", "type": "artifact", "level": 11, "stats": {"attack": 0, "critRate": 0.38, "comboRate": 0.34}, "quality": "common", "category": "equipment", "equipType": "artifact", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 11}, {"id": 1771671550387.9902, "name": "云雾裤子·道", "slot": "legs", "type": "legs", "level": 10, "stats": {"speed": 17, "defense": 20, "dodgeRate": 0.14}, "quality": "uncommon", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 10}, {"id": 1771671550387.83, "name": "紫金头部", "slot": "head", "type": "head", "level": 5, "stats": {"health": 119, "defense": 14, "stunResist": 0.13}, "quality": "common", "category": "equipment", "equipType": "head", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 5}, {"id": 1771671550387.6843, "name": "幽魄焰心链", "slot": "necklace", "type": "necklace", "level": 13, "stats": {"health": 210, "healBoost": 0.25, "spiritRate": 0.35}, "quality": "common", "category": "equipment", "equipType": "necklace", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 13}, {"id": 1771671550387.98, "name": "赤金手套·仙", "slot": "hands", "type": "hands", "level": 10, "stats": {"attack": 27, "critRate": 0.3, "comboRate": 0.26}, "quality": "epic", "category": "equipment", "equipType": "hands", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 10}, {"id": 1771671550387.1304, "name": "玄阳衣服·道", "slot": "body", "type": "body", "level": 10, "stats": {"health": 228, "defense": 23, "finalDamageReduce": 0.21}, "quality": "uncommon", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 10}, {"id": 1771671550387.822, "name": "玄风鞋子·道", "slot": "feet", "type": "feet", "level": 13, "stats": {"speed": 32, "defense": 19, "dodgeRate": 0.15}, "quality": "uncommon", "category": "equipment", "equipType": "feet", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 13}, {"id": 1771671550387.7256, "name": "九天焰杖·道", "slot": "weapon", "type": "weapon", "level": 3, "stats": {"attack": 16, "critRate": 0.14, "critDamageBoost": 0.27}, "quality": "uncommon", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 3}, {"id": 1771671550387.203, "name": "云霄头部·天", "slot": "head", "type": "head", "level": 6, "stats": {"health": 172, "defense": 23, "stunResist": 0.23}, "quality": "rare", "category": "equipment", "equipType": "head", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 6}, {"id": 1771671550387.1348, "name": "天珠焰心链", "slot": "necklace", "type": "necklace", "level": 9, "stats": {"health": 177, "healBoost": 0.2, "spiritRate": 0.3}, "quality": "common", "category": "equipment", "equipType": "necklace", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 9}, {"id": 1771671550387.9136, "name": "幽钢护腕·道", "slot": "wrist", "type": "wrist", "level": 10, "stats": {"defense": 17, "counterRate": 0.16, "vampireRate": 0.15}, "quality": "uncommon", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 10}, {"id": 1771671550387.4053, "name": "青锋肩甲", "slot": "shoulder", "type": "shoulder", "level": 6, "stats": {"health": 65, "defense": 16, "counterRate": 0.1}, "quality": "common", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 6}, {"id": 1771671550387.871, "name": "云踪鞋子", "slot": "feet", "type": "feet", "level": 12, "stats": {"speed": 30, "defense": 11, "dodgeRate": 0.12}, "quality": "common", "category": "equipment", "equipType": "feet", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 12}, {"id": 1771671550387.2122, "name": "混元衣服·天", "slot": "body", "type": "body", "level": 4, "stats": {"health": 249, "defense": 17, "finalDamageReduce": 0.18}, "quality": "rare", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 4}, {"id": 1771671550387.4995, "name": "云珠焰心链·道", "slot": "necklace", "type": "necklace", "level": 13, "stats": {"health": 211, "healBoost": 0.54, "spiritRate": 0.43}, "quality": "uncommon", "category": "equipment", "equipType": "necklace", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 13}, {"id": 1771671550387.0796, "name": "云雾裤子·仙", "slot": "legs", "type": "legs", "level": 10, "stats": {"speed": 24, "defense": 24, "dodgeRate": 0.23}, "quality": "epic", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 10}, {"id": 1771671550387.7537, "name": "赤命符文戒1", "slot": "ring1", "type": "ring1", "level": 4, "stats": {"attack": 9, "critDamageBoost": 0.15, "finalDamageBoost": 0.08}, "quality": "common", "category": "equipment", "equipType": "ring1", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 4}, {"id": 1771671550387.43, "name": "青命符文戒1", "slot": "ring1", "type": "ring1", "level": 11, "stats": {"attack": 18, "critDamageBoost": 0.38, "finalDamageBoost": 0.16}, "quality": "common", "category": "equipment", "equipType": "ring1", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 11}, {"id": 1771671550387.4424, "name": "玄宝焰器·道", "slot": "artifact", "type": "artifact", "level": 3, "stats": {"attack": 0, "critRate": 0.23, "comboRate": 0.16}, "quality": "uncommon", "category": "equipment", "equipType": "artifact", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 3}, {"id": 1771671550387.47, "name": "太素衣服·仙", "slot": "body", "type": "body", "level": 3, "stats": {"health": 306, "defense": 29, "finalDamageReduce": 0.18}, "quality": "epic", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 3}, {"id": 1771671550387.3005, "name": "混元衣服·仙", "slot": "body", "type": "body", "level": 7, "stats": {"health": 412, "defense": 36, "finalDamageReduce": 0.18}, "quality": "epic", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 7}, {"id": 1771671550387.4897, "name": "赤金手套·仙", "slot": "hands", "type": "hands", "level": 7, "stats": {"attack": 32, "critRate": 0.17, "comboRate": 0.23}, "quality": "epic", "category": "equipment", "equipType": "hands", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 7}, {"id": 1771671550387.554, "name": "幽银手套", "slot": "hands", "type": "hands", "level": 7, "stats": {"attack": 12, "critRate": 0.08, "comboRate": 0.13}, "quality": "common", "category": "equipment", "equipType": "hands", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 7}, {"id": 1771671550387.886, "name": "九天焰杖·天", "slot": "weapon", "type": "weapon", "level": 12, "stats": {"attack": 39, "critRate": 0.32, "critDamageBoost": 0.41}, "quality": "rare", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 12}], "message": "装备成功", "success": true, "computed_at": "2026-02-22T07:35:30.485Z", "state_version": 402, "equippedArtifacts": {"belt": null, "body": null, "feet": null, "head": null, "legs": {"id": 1771671550387.9841, "name": "星光裤子·天", "slot": "legs", "type": "legs", "level": 8, "stats": {"speed": 14, "defense": 31, "dodgeRate": 0.24}, "quality": "rare", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 8}, "hands": null, "ring1": null, "ring2": null, "wrist": null, "weapon": null, "artifact": null, "necklace": null, "shoulder": null}}	2026-02-22 02:35:30.489081-05
\.


--
-- Data for Name: inventory_items; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.inventory_items (id, player_id, original_id, name, type, quality, stats, attributes, enhance_level, required_realm, source, created_at) FROM stdin;
1	12	1771671442491.5056	混沌焰杖·圣	weapon	legendary	{"attack": 77, "critRate": 0.41, "critDamageBoost": 0.9}	{}	0	0	migration	2026-02-22 01:03:54.714791-05
2	10	1771656525094.8723	幽岚肩甲	shoulder	common	{"health": 131, "defense": 24, "counterRate": 0.19}	{}	0	0	migration	2026-02-22 01:03:54.719425-05
3	10	1771671516178.0571	紫电裤子	legs	common	{"speed": 15, "defense": 16, "dodgeRate": 0.11}	{}	0	0	migration	2026-02-22 01:03:54.727653-05
4	2	1771704541204.2527	天护肩甲·神	shoulder	mythic	{"health": 717, "defense": 152, "counterRate": 1.18}	{}	0	0	migration	2026-02-22 01:03:54.730807-05
5	2	1771704541204.7302	云霄头部·圣	head	legendary	{"health": 738, "defense": 101, "stunResist": 1.39}	{}	0	0	migration	2026-02-22 01:03:54.733468-05
6	2	1771704541204.5696	青龙衣服·道	body	uncommon	{"health": 616, "defense": 58, "finalDamageReduce": 0.43}	{}	0	0	migration	2026-02-22 01:03:54.735917-05
7	2	1771704541204.4072	玄武裤子·天	legs	rare	{"speed": 56, "defense": 74, "dodgeRate": 0.51}	{}	0	0	migration	2026-02-22 01:03:54.738465-05
8	2	1771704541204.362	紫命符文戒1	ring1	common	{"attack": 27, "critDamageBoost": 0.6, "finalDamageBoost": 0.46}	{}	0	0	migration	2026-02-22 01:03:54.740623-05
9	2	1771704541204.4988	赤焰鞋子	feet	common	{"speed": 68, "defense": 37, "dodgeRate": 0.45}	{}	0	0	migration	2026-02-22 01:03:54.742563-05
10	2	1771704541204.5361	玄宝焰器·道	artifact	uncommon	{"attack": 1, "critRate": 1.64, "comboRate": 1.78}	{}	0	0	migration	2026-02-22 01:03:54.744623-05
11	2	1771704541204.3096	赤宝焰器	artifact	common	{"attack": 1, "critRate": 0.63, "comboRate": 0.66}	{}	0	0	migration	2026-02-22 01:03:54.746394-05
12	2	1771704541204.6682	星晶护腕·仙	wrist	epic	{"defense": 65, "counterRate": 0.58, "vampireRate": 0.68}	{}	0	0	migration	2026-02-22 01:03:54.748217-05
13	2	1771704541204.0596	玄阳衣服	body	common	{"health": 492, "defense": 71, "finalDamageReduce": 0.3}	{}	0	0	migration	2026-02-22 01:03:54.749767-05
14	2	1771704541204.4248	玄冥头部·仙	head	epic	{"health": 933, "defense": 75, "stunResist": 0.63}	{}	0	0	migration	2026-02-22 01:03:54.751907-05
15	2	1771704541204.5798	紫晶手套	hands	common	{"attack": 28, "critRate": 0.26, "comboRate": 0.29}	{}	0	0	migration	2026-02-22 01:03:54.753585-05
16	2	1771704541204.3865	赤羽肩甲·道	shoulder	uncommon	{"health": 304, "defense": 51, "counterRate": 0.57}	{}	0	0	migration	2026-02-22 01:03:54.755078-05
17	2	1771704541204.6125	九霄衣服	body	common	{"health": 620, "defense": 47, "finalDamageReduce": 0.47}	{}	0	0	migration	2026-02-22 01:03:54.756531-05
18	2	1771704541204.2573	玄阳衣服·天	body	rare	{"health": 883, "defense": 96, "finalDamageReduce": 0.73}	{}	0	0	migration	2026-02-22 01:03:54.757976-05
19	2	1771704541204.6936	赤凤衣服	body	common	{"health": 784, "defense": 74, "finalDamageReduce": 0.52}	{}	0	0	migration	2026-02-22 01:03:54.760837-05
20	2	1771704541204.749	赤凤衣服	body	common	{"health": 758, "defense": 55, "finalDamageReduce": 0.55}	{}	0	0	migration	2026-02-22 01:03:54.762791-05
21	2	1771704541204.6394	幽宝焰器·道	artifact	uncommon	{"attack": 1, "critRate": 1.33, "comboRate": 0.91}	{}	0	0	migration	2026-02-22 01:03:54.764564-05
22	2	1771694198345.015	星辰头部·天	head	rare	{"health": 114, "defense": 19, "stunResist": 0}	{}	0	0	migration	2026-02-22 01:03:54.767693-05
23	2	1771682116225.4485	幽冥衣服·天	body	rare	{"health": 234, "defense": 19, "finalDamageReduce": 0.14}	{}	0	0	migration	2026-02-22 01:03:54.769365-05
24	2	1771693720415.478	青云裤子	legs	common	{"speed": 11, "defense": 10, "dodgeRate": 0.1}	{}	0	0	migration	2026-02-22 01:03:54.770839-05
25	2	1771696162778.795	幽影鞋子·道	feet	uncommon	{"speed": 18, "defense": 10, "dodgeRate": 0.12}	{}	0	0	migration	2026-02-22 01:03:54.773015-05
26	2	1771678854054.8857	紫雷肩甲·圣	shoulder	legendary	{"health": 144, "defense": 19, "counterRate": 0.15}	{}	0	0	migration	2026-02-22 01:03:54.774695-05
27	2	1771695640891.1904	天罗手套·仙	hands	epic	{"attack": 12, "critRate": 0.16, "comboRate": 0.17}	{}	0	0	migration	2026-02-22 01:03:54.776113-05
28	2	1771693284896.5388	星晶护腕·道	wrist	uncommon	{"defense": 9, "counterRate": 0.08, "vampireRate": 0.12}	{}	0	0	migration	2026-02-22 01:03:54.777782-05
29	2	1771607048414.5906	云珠焰心链·天	necklace	rare	{"health": 190, "healBoost": 0.3, "spiritRate": 0.25}	{}	0	0	migration	2026-02-22 01:03:54.779318-05
30	2	1771681436107.8853	星系腰带·仙	belt	epic	{"health": 175, "defense": 15, "combatBoost": 0.2}	{}	0	0	migration	2026-02-22 01:03:54.781959-05
31	2	1771694198345.4775	赤炎焰杖·圣	weapon	legendary	{"attack": 38, "critRate": 0.15, "critDamageBoost": 0.6}	{}	0	0	migration	2026-02-22 01:03:54.783539-05
32	2	1771695720218.171	混沌焰杖·仙	weapon	epic	{"attack": 85, "critRate": 0.31, "critDamageBoost": 1.87}	{}	8	0	migration	2026-02-22 01:03:54.78513-05
33	2	1771704541204.1484	玄系腰带·神	belt	mythic	{"health": 1095, "defense": 74, "combatBoost": 1.01}	{}	0	0	migration	2026-02-22 01:03:54.786764-05
34	2	1771704541204.5015	太素衣服·圣	body	legendary	{"health": 1438, "defense": 192, "finalDamageReduce": 0.92}	{}	0	0	migration	2026-02-22 01:03:54.790967-05
35	2	1771704541204.2964	天行鞋子·天	feet	rare	{"speed": 98, "defense": 43, "dodgeRate": 0.51}	{}	0	0	migration	2026-02-22 01:03:54.794043-05
36	2	1771704541204.8755	赤霞头部·仙	head	epic	{"health": 961, "defense": 103, "stunResist": 0.66}	{}	0	0	migration	2026-02-22 01:03:54.797515-05
37	2	1771704541204.0503	星光裤子·仙	legs	epic	{"speed": 95, "defense": 112, "dodgeRate": 0.9}	{}	0	0	migration	2026-02-22 01:03:54.800853-05
38	2	1771704541204.7039	紫晶手套·神	hands	mythic	{"attack": 159, "critRate": 1.19, "comboRate": 1.3}	{}	0	0	migration	2026-02-22 01:03:54.804051-05
39	2	1771704541204.2917	星命符文戒1·道	ring1	uncommon	{"attack": 39, "critDamageBoost": 1.14, "finalDamageBoost": 0.66}	{}	0	0	migration	2026-02-22 01:03:54.807409-05
40	2	1771704541204.8923	天道符文戒2·圣	ring2	legendary	{"defense": 108, "resistanceBoost": 1.36, "critDamageReduce": 2.16}	{}	0	0	migration	2026-02-22 01:03:54.810705-05
41	2	1771704541204.0178	赤铜护腕·圣	wrist	legendary	{"defense": 85, "counterRate": 0.71, "vampireRate": 1}	{}	0	0	migration	2026-02-22 01:03:54.814456-05
42	2	1771705874651.2534	九天焰杖·圣	weapon	legendary	{"attack": 197, "critRate": 1.42, "critDamageBoost": 3.51}	{}	0	0	migration	2026-02-22 01:03:54.817638-05
43	2	1771704541204.5774	赤宝焰器·仙	artifact	epic	{"attack": 3, "critRate": 1.42, "comboRate": 2.38}	{}	0	0	migration	2026-02-22 01:03:54.820471-05
44	2	1771704541204.7295	赤心焰心链	necklace	common	{"health": 663, "healBoost": 0.93, "spiritRate": 0.86}	{}	0	0	migration	2026-02-22 01:03:54.823451-05
45	2	1771704541204.7185	天护肩甲·神	shoulder	mythic	{"health": 853, "defense": 139, "counterRate": 1.1}	{}	0	0	migration	2026-02-22 01:03:54.828399-05
46	13	1771671550166.5647	赤铜护腕	wrist	common	{"defense": 5, "counterRate": 0.09, "vampireRate": 0.09}	{}	0	0	migration	2026-02-22 01:03:54.831483-05
47	13	1771671550219.6743	混元衣服	body	common	{"health": 145, "defense": 20, "finalDamageReduce": 0.08}	{}	0	0	migration	2026-02-22 01:03:54.833285-05
48	13	1771671550219.7185	幽系腰带·道	belt	uncommon	{"health": 176, "defense": 18, "combatBoost": 0.17}	{}	0	0	migration	2026-02-22 01:03:54.835149-05
49	13	1771671550219.0278	紫晶手套·道	hands	uncommon	{"attack": 22, "critRate": 0.08, "comboRate": 0.23}	{}	0	0	migration	2026-02-22 01:03:54.837005-05
50	13	1771671550219.7996	天护肩甲·道	shoulder	uncommon	{"health": 135, "defense": 12, "counterRate": 0.11}	{}	0	0	migration	2026-02-22 01:03:54.838991-05
51	13	1771671550219.5544	幽岚肩甲·道	shoulder	uncommon	{"health": 88, "defense": 14, "counterRate": 0.14}	{}	0	0	migration	2026-02-22 01:03:54.840945-05
52	13	1771671550387.261	混沌焰杖·道	weapon	uncommon	{"attack": 44, "critRate": 0.24, "critDamageBoost": 0.48}	{}	0	0	migration	2026-02-22 01:03:54.842746-05
53	13	1771671550387.607	九天焰杖·仙	weapon	epic	{"attack": 33, "critRate": 0.16, "critDamageBoost": 0.34}	{}	0	0	migration	2026-02-22 01:03:54.844555-05
54	13	1771671550387.8403	幽宝焰器	artifact	common	{"attack": 0, "critRate": 0.38, "comboRate": 0.34}	{}	0	0	migration	2026-02-22 01:03:54.846355-05
55	13	1771671550387.6062	云道符文戒2·天	ring2	rare	{"defense": 14, "resistanceBoost": 0.17, "critDamageReduce": 0.31}	{}	0	0	migration	2026-02-22 01:03:54.84818-05
56	13	1771671550387.9902	云雾裤子·道	legs	uncommon	{"speed": 17, "defense": 20, "dodgeRate": 0.14}	{}	0	0	migration	2026-02-22 01:03:54.850021-05
57	13	1771671550387.83	紫金头部	head	common	{"health": 119, "defense": 14, "stunResist": 0.13}	{}	0	0	migration	2026-02-22 01:03:54.851543-05
58	13	1771671550387.6843	幽魄焰心链	necklace	common	{"health": 210, "healBoost": 0.25, "spiritRate": 0.35}	{}	0	0	migration	2026-02-22 01:03:54.853096-05
59	13	1771671550387.98	赤金手套·仙	hands	epic	{"attack": 27, "critRate": 0.3, "comboRate": 0.26}	{}	0	0	migration	2026-02-22 01:03:54.854857-05
60	13	1771671550387.1304	玄阳衣服·道	body	uncommon	{"health": 228, "defense": 23, "finalDamageReduce": 0.21}	{}	0	0	migration	2026-02-22 01:03:54.856468-05
61	13	1771671550387.822	玄风鞋子·道	feet	uncommon	{"speed": 32, "defense": 19, "dodgeRate": 0.15}	{}	0	0	migration	2026-02-22 01:03:54.858054-05
62	13	1771671550387.7256	九天焰杖·道	weapon	uncommon	{"attack": 16, "critRate": 0.14, "critDamageBoost": 0.27}	{}	0	0	migration	2026-02-22 01:03:54.859627-05
63	13	1771671550387.203	云霄头部·天	head	rare	{"health": 172, "defense": 23, "stunResist": 0.23}	{}	0	0	migration	2026-02-22 01:03:54.860979-05
64	13	1771671550387.1348	天珠焰心链	necklace	common	{"health": 177, "healBoost": 0.2, "spiritRate": 0.3}	{}	0	0	migration	2026-02-22 01:03:54.862365-05
65	13	1771671550387.9136	幽钢护腕·道	wrist	uncommon	{"defense": 17, "counterRate": 0.16, "vampireRate": 0.15}	{}	0	0	migration	2026-02-22 01:03:54.864755-05
66	13	1771671550387.4053	青锋肩甲	shoulder	common	{"health": 65, "defense": 16, "counterRate": 0.1}	{}	0	0	migration	2026-02-22 01:03:54.866704-05
67	13	1771671550387.871	云踪鞋子	feet	common	{"speed": 30, "defense": 11, "dodgeRate": 0.12}	{}	0	0	migration	2026-02-22 01:03:54.868356-05
68	13	1771671550387.2122	混元衣服·天	body	rare	{"health": 249, "defense": 17, "finalDamageReduce": 0.18}	{}	0	0	migration	2026-02-22 01:03:54.870372-05
69	13	1771671550387.4995	云珠焰心链·道	necklace	uncommon	{"health": 211, "healBoost": 0.54, "spiritRate": 0.43}	{}	0	0	migration	2026-02-22 01:03:54.872118-05
70	13	1771671550387.0796	云雾裤子·仙	legs	epic	{"speed": 24, "defense": 24, "dodgeRate": 0.23}	{}	0	0	migration	2026-02-22 01:03:54.873692-05
71	13	1771671550387.7537	赤命符文戒1	ring1	common	{"attack": 9, "critDamageBoost": 0.15, "finalDamageBoost": 0.08}	{}	0	0	migration	2026-02-22 01:03:54.875391-05
72	13	1771671550387.43	青命符文戒1	ring1	common	{"attack": 18, "critDamageBoost": 0.38, "finalDamageBoost": 0.16}	{}	0	0	migration	2026-02-22 01:03:54.877029-05
73	13	1771671550387.4424	玄宝焰器·道	artifact	uncommon	{"attack": 0, "critRate": 0.23, "comboRate": 0.16}	{}	0	0	migration	2026-02-22 01:03:54.878622-05
74	13	1771671550387.47	太素衣服·仙	body	epic	{"health": 306, "defense": 29, "finalDamageReduce": 0.18}	{}	0	0	migration	2026-02-22 01:03:54.88037-05
75	13	1771671550387.3005	混元衣服·仙	body	epic	{"health": 412, "defense": 36, "finalDamageReduce": 0.18}	{}	0	0	migration	2026-02-22 01:03:54.882107-05
76	13	1771671550387.4897	赤金手套·仙	hands	epic	{"attack": 32, "critRate": 0.17, "comboRate": 0.23}	{}	0	0	migration	2026-02-22 01:03:54.883953-05
77	13	1771671550387.554	幽银手套	hands	common	{"attack": 12, "critRate": 0.08, "comboRate": 0.13}	{}	0	0	migration	2026-02-22 01:03:54.885696-05
78	13	1771671550387.886	九天焰杖·天	weapon	rare	{"attack": 39, "critRate": 0.32, "critDamageBoost": 0.41}	{}	0	0	migration	2026-02-22 01:03:54.887708-05
79	13	1771671550387.9841	星光裤子·天	legs	rare	{"speed": 14, "defense": 31, "dodgeRate": 0.24}	{}	0	0	migration	2026-02-22 01:03:54.889589-05
80	13	1771671550387.0518	星宝焰器·道	artifact	uncommon	{"attack": 1, "critRate": 0.63, "comboRate": 0.71}	{}	0	0	migration	2026-02-22 01:03:54.891439-05
81	13	1771671550387.3079	云雾裤子	legs	common	{"speed": 14, "defense": 10, "dodgeRate": 0.14}	{}	0	0	migration	2026-02-22 01:03:54.893182-05
82	13	1771671550387.938	玄圣焰心链	necklace	common	{"health": 123, "healBoost": 0.31, "spiritRate": 0.24}	{}	0	0	migration	2026-02-22 01:03:54.894795-05
83	13	1771671550387.8188	赤金手套·天	hands	rare	{"attack": 18, "critRate": 0.12, "comboRate": 0.2}	{}	0	0	migration	2026-02-22 01:03:54.896523-05
84	13	1771671550387.6348	紫系腰带·道	belt	uncommon	{"health": 77, "defense": 9, "combatBoost": 0.18}	{}	0	0	migration	2026-02-22 01:03:54.897985-05
85	13	1771671550387.749	天珠焰心链	necklace	common	{"health": 127, "healBoost": 0.2, "spiritRate": 0.2}	{}	0	0	migration	2026-02-22 01:03:54.899595-05
86	13	1771671550387.9258	天绝护腕·天	wrist	rare	{"defense": 14, "counterRate": 0.25, "vampireRate": 0.19}	{}	0	0	migration	2026-02-22 01:03:54.901147-05
87	13	1771671550387.3115	青莲鞋子·圣	feet	legendary	{"speed": 32, "defense": 30, "dodgeRate": 0.37}	{}	0	0	migration	2026-02-22 01:03:54.902647-05
88	13	1771671550387.189	赤命符文戒1·道	ring1	uncommon	{"attack": 22, "critDamageBoost": 0.37, "finalDamageBoost": 0.21}	{}	0	0	migration	2026-02-22 01:03:54.904141-05
89	13	1771671550387.9033	赤炎焰杖	weapon	common	{"attack": 15, "critRate": 0.14, "critDamageBoost": 0.26}	{}	0	0	migration	2026-02-22 01:03:54.905808-05
90	13	1771671550387.3376	青系腰带·道	belt	uncommon	{"health": 130, "defense": 10, "combatBoost": 0.16}	{}	0	0	migration	2026-02-22 01:03:54.907238-05
91	13	1771671550387.2876	玄命符文戒1·道	ring1	uncommon	{"attack": 18, "critDamageBoost": 0.24, "finalDamageBoost": 0.19}	{}	0	0	migration	2026-02-22 01:03:54.908602-05
92	13	1771671550387.1743	天珠焰心链	necklace	common	{"health": 142, "healBoost": 0.28, "spiritRate": 0.28}	{}	0	0	migration	2026-02-22 01:03:54.910025-05
93	13	1771671550387.584	赤铜护腕·道	wrist	uncommon	{"defense": 10, "counterRate": 0.18, "vampireRate": 0.15}	{}	0	0	migration	2026-02-22 01:03:54.911707-05
94	13	1771671550387.1511	青龙衣服	body	common	{"health": 152, "defense": 18, "finalDamageReduce": 0.1}	{}	0	0	migration	2026-02-22 01:03:54.913151-05
95	13	1771671550387.5928	赤道符文戒2	ring2	common	{"defense": 11, "resistanceBoost": 0.11, "critDamageReduce": 0.37}	{}	0	0	migration	2026-02-22 01:03:54.9147-05
96	13	1771671550387.812	赤炎焰杖·天	weapon	rare	{"attack": 46, "critRate": 0.17, "critDamageBoost": 0.58}	{}	0	0	migration	2026-02-22 01:03:54.91609-05
97	13	1771671550387.6099	星光裤子	legs	common	{"speed": 16, "defense": 16, "dodgeRate": 0.16}	{}	0	0	migration	2026-02-22 01:03:54.917513-05
98	13	1771671550387.5217	玄铁护腕	wrist	common	{"defense": 9, "counterRate": 0.13, "vampireRate": 0.11}	{}	0	0	migration	2026-02-22 01:03:54.918997-05
99	13	1771671550387.9197	紫电裤子	legs	common	{"speed": 17, "defense": 20, "dodgeRate": 0.14}	{}	0	0	migration	2026-02-22 01:03:54.920439-05
100	13	1771671550387.6511	星道符文戒2·道	ring2	uncommon	{"defense": 11, "resistanceBoost": 0.17, "critDamageReduce": 0.32}	{}	0	0	migration	2026-02-22 01:03:54.922014-05
101	13	1771671550387.0647	天罡裤子·仙	legs	epic	{"speed": 32, "defense": 35, "dodgeRate": 0.22}	{}	0	0	migration	2026-02-22 01:03:54.923966-05
102	13	1771671464433.3562	云甲肩甲·道	shoulder	uncommon	{"health": 121, "defense": 13, "counterRate": 0.09}	{}	0	0	migration	2026-02-22 01:03:54.925419-05
103	13	1771671531719.224	天行鞋子·仙	feet	epic	{"speed": 51, "defense": 19, "dodgeRate": 0.25}	{}	0	0	migration	2026-02-22 01:03:54.926753-05
104	13	1771671542604.0227	玄系腰带	belt	common	{"health": 89, "defense": 12, "combatBoost": 0.19}	{}	0	0	migration	2026-02-22 01:03:54.928158-05
105	18	1771839683084.9338	混元衣服·天	body	rare	{"health": 318, "defense": 38, "finalDamageReduce": 0.25}	{}	0	0	game	2026-02-23 04:42:35.756402-05
106	18	1771839683084.0916	紫霞鞋子	feet	common	{"speed": 12, "defense": 6, "dodgeRate": 0.02}	{}	0	0	game	2026-02-23 04:42:36.141351-05
107	18	1771839683084.7969	幽岚肩甲	shoulder	common	{"health": 85, "defense": 9, "counterRate": 0.03}	{}	0	0	game	2026-02-23 04:42:36.433816-05
108	18	1771839683084.6914	紫晶手套·道	hands	uncommon	{"attack": 12, "critRate": 0.03, "comboRate": 0.03}	{}	0	0	game	2026-02-23 04:42:36.836969-05
109	18	1771839683084.151	云珠焰心链	necklace	common	{"health": 115, "healBoost": 0.04, "spiritRate": 0.05}	{}	0	0	game	2026-02-23 04:42:37.14525-05
110	18	1771839683084.4546	星命符文戒1·天	ring1	rare	{"attack": 22, "critDamageBoost": 0.09, "finalDamageBoost": 0.05}	{}	0	0	game	2026-02-23 04:42:37.436115-05
111	18	1771839683084.0752	紫系腰带·道	belt	uncommon	{"health": 103, "defense": 10, "combatBoost": 0.04}	{}	0	0	game	2026-02-23 04:42:37.729823-05
112	2	1771870822641.1128	太虚焰杖·仙	weapon	epic	{"attack": 395, "critRate": 0.39, "critDamageBoost": 1.37}	{}	0	0	game	2026-02-23 23:29:08.419683-05
113	2	1771846942472.0234	青玉头部·圣	head	legendary	{"health": 2478, "defense": 343, "stunResist": 3.27}	{}	0	0	game	2026-02-23 23:29:08.677726-05
114	2	1771846942472.5728	赤凤衣服·仙	body	epic	{"health": 3464, "defense": 375, "finalDamageReduce": 2.05}	{}	0	0	game	2026-02-23 23:29:09.048784-05
115	2	1771846942472.5024	玄甲肩甲·仙	shoulder	epic	{"health": 1822, "defense": 274, "counterRate": 0.8}	{}	0	0	game	2026-02-23 23:29:09.287748-05
116	2	1771846942472.381	紫玉护腕·圣	wrist	legendary	{"defense": 198, "counterRate": 1.07, "vampireRate": 0.56}	{}	0	0	game	2026-02-23 23:29:09.519164-05
117	2	1771846942472.5771	星魂焰心链·仙	necklace	epic	{"health": 2683, "healBoost": 0.94, "spiritRate": 1}	{}	0	0	game	2026-02-23 23:29:09.746625-05
118	2	1771846942472.6626	云命符文戒1·圣	ring1	legendary	{"attack": 274, "critDamageBoost": 1.49, "finalDamageBoost": 0.62}	{}	0	0	game	2026-02-23 23:29:09.980711-05
119	2	1771938014225.4658	紫电裤子·仙	legs	epic	{"speed": 155, "defense": 220, "dodgeRate": 0.78}	{}	0	0	game	2026-02-24 10:45:04.834838-05
120	2	1771947814103.9165	紫霞鞋子·仙	feet	epic	{"speed": 362, "defense": 175, "dodgeRate": 0.32}	{}	0	0	game	2026-02-24 10:45:05.439659-05
121	2	1771938665053.1423	云甲肩甲·仙	shoulder	epic	{"health": 2169, "defense": 252, "counterRate": 0.71}	{}	0	0	game	2026-02-24 10:45:06.068005-05
122	2	1771947814103.8193	紫晶手套·仙	hands	epic	{"attack": 174, "critRate": 0.2, "comboRate": 0.83}	{}	0	0	game	2026-02-24 10:45:06.928221-05
123	2	1771947814103.883	青石护腕·圣	wrist	legendary	{"defense": 349, "counterRate": 1.2, "vampireRate": 1.43}	{}	0	0	game	2026-02-24 10:45:07.400947-05
124	2	1771947793188.2927	天命符文戒1·圣	ring1	legendary	{"attack": 367, "critDamageBoost": 1.07, "finalDamageBoost": 1.41}	{}	0	0	game	2026-02-24 10:45:08.059021-05
125	2	1771947814103.2275	星道符文戒2·仙	ring2	epic	{"defense": 245, "resistanceBoost": 0.85, "critDamageReduce": 0.64}	{}	0	0	game	2026-02-24 10:45:08.643888-05
126	2	1771947814103.454	青系腰带·仙	belt	epic	{"health": 1403, "defense": 207, "combatBoost": 0.37}	{}	0	0	game	2026-02-24 10:45:09.376973-05
\.


--
-- Data for Name: leaderboard_cache; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.leaderboard_cache (id, type, data, updated_at) FROM stdin;
1	level	[{"name": "测试账号 1", "rank": 1, "level": 74, "realm": "渡焰二重", "score": 74, "wallet": "0x82e402b05f3e936b63a874788c73e1552657c4f7", "vip_level": 5, "combat_power": 52869, "total_recharge": "1015.00000000"}, {"name": "无名焰修", "rank": 2, "level": 24, "realm": "凝焰六重", "score": 24, "wallet": "0xc385d64735689929311621f4e81ca5b4e7830055", "vip_level": 3, "combat_power": 225, "total_recharge": "234.00000000"}, {"name": "无名焰修", "rank": 3, "level": 2, "realm": "燃火二重", "score": 2, "wallet": "0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5", "vip_level": 0, "combat_power": 225, "total_recharge": "0.00000000"}, {"name": "索罗斯二世", "rank": 4, "level": 2, "realm": "燃火二重", "score": 2, "wallet": "0x2f3a3513f2973a66e26850cc7a1baab6363d1b8f", "vip_level": 0, "combat_power": 1895, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 5, "level": 1, "realm": "燃火期一层", "score": 1, "wallet": "0xadb0ecf47e175089579da5182dd7707328575909", "vip_level": 0, "combat_power": 225, "total_recharge": "2.00000000"}, {"name": "无名修士", "rank": 6, "level": 1, "realm": "燃火期一层", "score": 1, "wallet": "0x1dbbef8203a357b35a0da09f5ab4e1a5e19528ec", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 7, "level": 1, "realm": "燃火期一层", "score": 1, "wallet": "0xa40d60613f61e8546a9e3348b1f31630443485ba", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "野猪佩奇", "rank": 8, "level": 1, "realm": "燃火期一层", "score": 1, "wallet": "0x7c402b2d8c7d48414d5f1eb4dd6522d04992c023", "vip_level": 0, "combat_power": 325, "total_recharge": "0.00000000"}, {"name": "测试焰修", "rank": 9, "level": 1, "realm": "燃火期一层", "score": 1, "wallet": "0x53b07cbaefe27255578c912a9dde76bbf0f3ca16", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "无名焰修", "rank": 10, "level": 1, "realm": "燃火期一层", "score": 1, "wallet": "0x602faa4d15c6df9468fbffb44618cf21834d231b", "vip_level": 0, "combat_power": 425, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 11, "level": 1, "realm": "燃火期一层", "score": 1, "wallet": "0xf55dc98d490893d3e6be354bc01cdd7ca49e3eb9", "vip_level": 0, "combat_power": 225, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 12, "level": 1, "realm": "燃火期一层", "score": 1, "wallet": "0xfad7eb0814b6838b05191a07fb987957d50c4ca9", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 13, "level": 1, "realm": "燃火期一层", "score": 1, "wallet": "0x5b5717754beb158c384281cbec4c8a4682a1e4f8", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 14, "level": 1, "realm": "燃火期一层", "score": 1, "wallet": "0x207e30521e0903e2a0288ed162243dc740598c06", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 15, "level": 1, "realm": "燃火期一层", "score": 1, "wallet": "0xbf66c656b2aff9d39f2329e5b332f5e68600fe65", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}]	2026-02-25 01:36:15.17124
2	combat_power	[{"name": "测试账号 1", "rank": 1, "level": 74, "realm": "渡焰二重", "score": "52869", "wallet": "0x82e402b05f3e936b63a874788c73e1552657c4f7", "vip_level": 5, "combat_power": 52869, "total_recharge": "1015.00000000"}, {"name": "索罗斯二世", "rank": 2, "level": 2, "realm": "燃火二重", "score": "1895", "wallet": "0x2f3a3513f2973a66e26850cc7a1baab6363d1b8f", "vip_level": 0, "combat_power": 1895, "total_recharge": "0.00000000"}, {"name": "无名焰修", "rank": 3, "level": 1, "realm": "燃火期一层", "score": "425", "wallet": "0x602faa4d15c6df9468fbffb44618cf21834d231b", "vip_level": 0, "combat_power": 425, "total_recharge": "0.00000000"}, {"name": "野猪佩奇", "rank": 4, "level": 1, "realm": "燃火期一层", "score": "325", "wallet": "0x7c402b2d8c7d48414d5f1eb4dd6522d04992c023", "vip_level": 0, "combat_power": 325, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 5, "level": 1, "realm": "燃火期一层", "score": "225", "wallet": "0xf55dc98d490893d3e6be354bc01cdd7ca49e3eb9", "vip_level": 0, "combat_power": 225, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 6, "level": 1, "realm": "燃火期一层", "score": "225", "wallet": "0xadb0ecf47e175089579da5182dd7707328575909", "vip_level": 0, "combat_power": 225, "total_recharge": "2.00000000"}, {"name": "无名焰修", "rank": 7, "level": 2, "realm": "燃火二重", "score": "225", "wallet": "0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5", "vip_level": 0, "combat_power": 225, "total_recharge": "0.00000000"}, {"name": "无名焰修", "rank": 8, "level": 24, "realm": "凝焰六重", "score": "225", "wallet": "0xc385d64735689929311621f4e81ca5b4e7830055", "vip_level": 3, "combat_power": 225, "total_recharge": "234.00000000"}, {"name": "无名修士", "rank": 9, "level": 1, "realm": "燃火期一层", "score": "0", "wallet": "0xfad7eb0814b6838b05191a07fb987957d50c4ca9", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 10, "level": 1, "realm": "燃火期一层", "score": "0", "wallet": "0xa40d60613f61e8546a9e3348b1f31630443485ba", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 11, "level": 1, "realm": "燃火期一层", "score": "0", "wallet": "0xbf66c656b2aff9d39f2329e5b332f5e68600fe65", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "测试焰修", "rank": 12, "level": 1, "realm": "燃火期一层", "score": "0", "wallet": "0x53b07cbaefe27255578c912a9dde76bbf0f3ca16", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 13, "level": 1, "realm": "燃火期一层", "score": "0", "wallet": "0x207e30521e0903e2a0288ed162243dc740598c06", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 14, "level": 1, "realm": "燃火期一层", "score": "0", "wallet": "0x5b5717754beb158c384281cbec4c8a4682a1e4f8", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 15, "level": 1, "realm": "燃火期一层", "score": "0", "wallet": "0x1dbbef8203a357b35a0da09f5ab4e1a5e19528ec", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}]	2026-02-25 01:36:15.178251
5	recharge	[{"name": "测试账号 1", "rank": 1, "level": 74, "realm": "渡焰二重", "score": "1015.00000000", "wallet": "0x82e402b05f3e936b63a874788c73e1552657c4f7", "vip_level": 5, "combat_power": 52869, "total_recharge": "1015.00000000"}, {"name": "无名焰修", "rank": 2, "level": 24, "realm": "凝焰六重", "score": "234.00000000", "wallet": "0xc385d64735689929311621f4e81ca5b4e7830055", "vip_level": 3, "combat_power": 225, "total_recharge": "234.00000000"}, {"name": "无名修士", "rank": 3, "level": 1, "realm": "燃火期一层", "score": "2.00000000", "wallet": "0xadb0ecf47e175089579da5182dd7707328575909", "vip_level": 0, "combat_power": 225, "total_recharge": "2.00000000"}, {"name": "无名修士", "rank": 4, "level": 1, "realm": "燃火期一层", "score": "0.00000000", "wallet": "0xbf66c656b2aff9d39f2329e5b332f5e68600fe65", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 5, "level": 1, "realm": "燃火期一层", "score": "0.00000000", "wallet": "0x1dbbef8203a357b35a0da09f5ab4e1a5e19528ec", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "无名焰修", "rank": 6, "level": 2, "realm": "燃火二重", "score": "0.00000000", "wallet": "0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5", "vip_level": 0, "combat_power": 225, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 7, "level": 1, "realm": "燃火期一层", "score": "0.00000000", "wallet": "0xa40d60613f61e8546a9e3348b1f31630443485ba", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "野猪佩奇", "rank": 8, "level": 1, "realm": "燃火期一层", "score": "0.00000000", "wallet": "0x7c402b2d8c7d48414d5f1eb4dd6522d04992c023", "vip_level": 0, "combat_power": 325, "total_recharge": "0.00000000"}, {"name": "测试焰修", "rank": 9, "level": 1, "realm": "燃火期一层", "score": "0.00000000", "wallet": "0x53b07cbaefe27255578c912a9dde76bbf0f3ca16", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "无名焰修", "rank": 10, "level": 1, "realm": "燃火期一层", "score": "0.00000000", "wallet": "0x602faa4d15c6df9468fbffb44618cf21834d231b", "vip_level": 0, "combat_power": 425, "total_recharge": "0.00000000"}, {"name": "索罗斯二世", "rank": 11, "level": 2, "realm": "燃火二重", "score": "0.00000000", "wallet": "0x2f3a3513f2973a66e26850cc7a1baab6363d1b8f", "vip_level": 0, "combat_power": 1895, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 12, "level": 1, "realm": "燃火期一层", "score": "0.00000000", "wallet": "0xf55dc98d490893d3e6be354bc01cdd7ca49e3eb9", "vip_level": 0, "combat_power": 225, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 13, "level": 1, "realm": "燃火期一层", "score": "0.00000000", "wallet": "0xfad7eb0814b6838b05191a07fb987957d50c4ca9", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 14, "level": 1, "realm": "燃火期一层", "score": "0.00000000", "wallet": "0x5b5717754beb158c384281cbec4c8a4682a1e4f8", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}, {"name": "无名修士", "rank": 15, "level": 1, "realm": "燃火期一层", "score": "0.00000000", "wallet": "0x207e30521e0903e2a0288ed162243dc740598c06", "vip_level": 0, "combat_power": 0, "total_recharge": "0.00000000"}]	2026-02-25 01:36:15.181862
\.


--
-- Data for Name: login_logs; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.login_logs (id, wallet, ip, user_agent, created_at) FROM stdin;
1	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-21 14:07:25.541966
2	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-21 14:07:36.903683
3	0x82e402b05f3e936b63a874788c73e1552657c4f7	156.229.160.165	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	2026-02-21 14:23:11.7935
4	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-21 14:52:06.156577
5	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-21 22:53:37.909287
6	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-21 22:56:02.071075
7	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-21 23:09:41.015974
8	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-21 23:25:02.523753
9	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-21 23:28:45.710017
10	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-21 23:30:00.996127
11	0x53b07cbaefe27255578c912a9dde76bbf0f3ca16	127.0.0.1	node	2026-02-22 00:55:16.561969
12	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 01:51:13.34883
13	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 02:29:14.03241
14	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 03:18:55.804971
15	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 05:40:05.993043
16	0x602faa4d15c6df9468fbffb44618cf21834d231b	103.77.192.217	Mozilla/5.0 (Linux; Android 16; A024 Build/BQ2A.250721.001-BP2A.250605.031.A3; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.132 Mobile Safari/537.36 OKX-Wallet-google/6.158	2026-02-22 08:29:25.59432
17	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 09:04:43.019844
18	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 09:10:07.915663
19	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 09:16:05.009379
20	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 09:18:26.698377
21	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 12:17:02.180055
22	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 12:17:41.257089
23	0x7c402b2d8c7d48414d5f1eb4dd6522d04992c023	154.92.130.100	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	2026-02-22 12:24:16.497851
24	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 19:31:56.051924
25	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 19:35:00.230142
26	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 19:47:15.832292
27	0x82e402b05f3e936b63a874788c73e1552657c4f7	156.229.160.165	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	2026-02-22 20:34:49.976177
28	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 21:05:13.635663
29	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 21:08:12.139981
30	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 21:14:12.167614
31	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 21:52:16.05418
32	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 21:57:07.371042
33	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 22:00:30.563614
34	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 22:23:20.050897
35	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-22 22:45:26.597714
36	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 00:57:45.900212
37	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 00:59:14.363203
38	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 01:36:45.460966
39	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 04:18:31.342025
40	0x2f3a3513f2973a66e26850cc7a1baab6363d1b8f	157.10.251.70	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-02-23 04:31:48.208534
41	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 04:48:23.962612
42	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 04:53:44.876956
43	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 06:24:39.603073
44	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 06:29:14.96583
45	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 06:30:26.585855
46	0xc385d64735689929311621f4e81ca5b4e7830055	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 06:31:45.110787
47	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 06:32:53.338522
48	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 06:50:55.460276
49	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 06:56:18.545092
50	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 07:14:44.66589
51	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 07:15:17.58348
52	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 13:12:00.395244
53	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 13:16:20.289402
54	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 13:18:05.44394
55	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 13:22:14.726479
56	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 13:23:52.242748
57	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 13:29:21.681189
58	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 13:32:42.734709
59	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 13:34:27.806041
60	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 13:35:08.643683
61	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 13:40:41.595386
62	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 13:44:29.265038
63	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 13:55:16.634861
64	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 21:00:55.782648
65	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 21:09:55.664102
66	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 23:03:04.94303
67	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 23:05:35.038043
68	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 23:06:03.425668
69	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 23:09:43.724342
70	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 23:09:55.162162
71	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 23:12:35.942081
72	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 23:13:09.316509
73	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 23:15:16.70416
74	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 23:20:56.098032
75	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 23:33:18.750441
76	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 23:41:33.719451
77	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 23:42:16.007333
78	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-23 23:55:19.879103
79	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 01:07:29.647869
80	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 01:48:33.17329
81	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 02:59:54.758284
82	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 03:32:16.409004
83	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 03:35:02.427166
84	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 03:58:05.763541
85	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 06:01:42.017798
86	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 06:04:13.292066
87	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 06:07:32.737943
88	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 06:08:37.899492
89	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 06:10:50.238772
90	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 06:15:49.848975
91	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 06:16:11.340561
92	0x1dbbef8203a357b35a0da09f5ab4e1a5e19528ec	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 Phantom/ios/26.4.0.39858	2026-02-24 06:20:22.691448
93	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 06:32:51.110331
94	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 09:14:38.260789
95	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 09:18:36.487513
96	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 09:20:20.814082
97	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 09:26:17.661703
98	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 09:29:20.745224
99	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 09:33:21.976002
100	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 09:34:10.423407
101	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 11:05:15.09813
102	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 11:05:43.472951
103	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 11:07:39.566658
104	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 11:22:08.639344
105	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 11:23:50.060715
106	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 11:56:05.784393
107	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 12:25:19.29821
108	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 12:46:08.345569
109	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 12:48:05.406334
110	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 12:57:01.789552
111	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 13:10:10.581639
112	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 13:23:46.497784
113	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 13:27:36.390081
114	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 13:28:19.99174
115	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 13:32:04.100006
116	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 13:40:51.493941
117	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 13:42:32.06473
118	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 13:45:59.276958
119	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 13:48:41.749996
120	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 13:56:29.844011
121	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 14:01:14.936597
122	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 14:06:46.204534
123	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 14:11:28.137295
124	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 14:13:19.927513
125	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 14:14:23.07196
126	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 14:43:05.961026
127	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 14:55:17.955812
128	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 19:45:22.29187
129	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 19:46:35.932029
130	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 20:05:45.642565
131	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 20:06:18.228534
132	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 20:10:34.774117
133	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 20:32:34.869094
134	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 20:37:21.093745
135	0x82e402b05f3e936b63a874788c73e1552657c4f7	140.235.143.151	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TokenPocket_iOS TokenPocket/iOS	2026-02-24 20:37:32.210739
\.


--
-- Data for Name: minigame_scores; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.minigame_scores (id, wallet, month, total_score) FROM stdin;
\.


--
-- Data for Name: monthly_cards; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.monthly_cards (id, wallet, purchased_at, expires_at, last_claim_date, days_claimed) FROM stdin;
\.


--
-- Data for Name: monthly_rankings; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.monthly_rankings (id, month, rank_type, rank_position, wallet, player_name, score, reward_roon, reward_stones, claimed, created_at) FROM stdin;
\.


--
-- Data for Name: monthly_revenue; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.monthly_revenue (id, month, total_roon, reward_pool, snapshot_done, distributed, created_at) FROM stdin;
\.


--
-- Data for Name: monthly_spending; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.monthly_spending (id, wallet, month, total_spent) FROM stdin;
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
-- Data for Name: pk_rankings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pk_rankings (id, wallet, rank_score, rank_tier, season, wins, losses, draws, win_streak, max_win_streak, last_pk_at, created_at, updated_at) FROM stdin;
17	0xbot004	1010	silver	1	1	0	0	1	0	2026-02-24 14:12:08.148041-05	2026-02-24 13:15:37.20158-05	2026-02-24 13:15:37.20158-05
14	0xbot001	1010	silver	1	1	0	0	1	0	2026-02-24 14:12:36.004013-05	2026-02-24 13:15:37.188334-05	2026-02-24 13:15:37.188334-05
19	0xbot006	1010	silver	1	1	0	0	1	0	2026-02-24 14:19:47.096918-05	2026-02-24 13:15:37.207211-05	2026-02-24 13:15:37.207211-05
21	0xbot008	1010	silver	1	1	0	0	1	0	2026-02-24 20:07:03.31742-05	2026-02-24 13:15:37.212547-05	2026-02-24 13:15:37.212547-05
18	0xbot005	1010	silver	1	1	0	0	1	0	2026-02-24 21:21:03.864154-05	2026-02-24 13:15:37.204951-05	2026-02-24 13:15:37.204951-05
1	0x82e402b05f3e936b63a874788c73e1552657c4f7	1020	silver	1	4	5	0	1	2	2026-02-24 21:24:54.806038-05	2026-02-23 12:19:06.558075-05	2026-02-23 12:19:06.558075-05
68	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	925	bronze	1	0	4	0	0	0	2026-02-24 21:24:54.808028-05	2026-02-24 13:27:45.649305-05	2026-02-24 13:27:45.649305-05
16	0xbot003	1000	silver	1	0	0	0	0	0	2026-02-24 13:46:39.855828-05	2026-02-24 13:15:37.198446-05	2026-02-24 13:15:37.198446-05
20	0xbot007	1000	silver	1	0	0	0	0	0	2026-02-24 14:02:49.41653-05	2026-02-24 13:15:37.209801-05	2026-02-24 13:15:37.209801-05
15	0xbot002	1000	silver	1	0	0	0	0	0	2026-02-24 14:03:39.43754-05	2026-02-24 13:15:37.194924-05	2026-02-24 13:15:37.194924-05
\.


--
-- Data for Name: pk_records; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.pk_records (id, wallet_a, wallet_b, name_a, name_b, winner, winner_wallet, rounds_data, reward, created_at, bet_amount, score_change_a, score_change_b) FROM stdin;
\.


--
-- Data for Name: pk_season_history; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.pk_season_history (id, season_num, wallet, rank_score, rank_tier, wins, losses, draws, max_win_streak, final_rank, reward_stones, reward_title, created_at) FROM stdin;
\.


--
-- Data for Name: pk_seasons; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.pk_seasons (id, season_num, month, start_date, end_date, status, created_at) FROM stdin;
\.


--
-- Data for Name: player_mail; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.player_mail (id, to_wallet, from_type, from_name, title, content, rewards, is_read, is_claimed, expires_at, created_at, from_wallet) FROM stdin;
1	0xf55dc98d490893d3e6be354bc01cdd7ca49e3eb9	admin	管理员	🔥 欢迎来到火之文明	感谢你加入焰修世界！这是一份新手礼物，祝你修炼顺利！	{"spiritStones": 5000, "reinforceStones": 10}	f	f	\N	2026-02-21 07:18:33.768602-05	\N
2	0x207e30521e0903e2a0288ed162243dc740598c06	admin	管理员	🔥 欢迎来到火之文明	感谢你加入焰修世界！这是一份新手礼物，祝你修炼顺利！	{"spiritStones": 5000, "reinforceStones": 10}	f	f	\N	2026-02-21 07:18:33.773237-05	\N
4	0xbf66c656b2aff9d39f2329e5b332f5e68600fe65	admin	管理员	🔥 欢迎来到火之文明	感谢你加入焰修世界！这是一份新手礼物，祝你修炼顺利！	{"spiritStones": 5000, "reinforceStones": 10}	f	f	\N	2026-02-21 07:18:33.77687-05	\N
5	0x5b5717754beb158c384281cbec4c8a4682a1e4f8	admin	管理员	🔥 欢迎来到火之文明	感谢你加入焰修世界！这是一份新手礼物，祝你修炼顺利！	{"spiritStones": 5000, "reinforceStones": 10}	f	f	\N	2026-02-21 07:18:33.778517-05	\N
6	0xbot0000000000000000000000000000000000d4	admin	管理员	🔥 欢迎来到火之文明	感谢你加入焰修世界！这是一份新手礼物，祝你修炼顺利！	{"spiritStones": 5000, "reinforceStones": 10}	f	f	\N	2026-02-21 07:18:33.780127-05	\N
7	0xbot0000000000000000000000000000000000e5	admin	管理员	🔥 欢迎来到火之文明	感谢你加入焰修世界！这是一份新手礼物，祝你修炼顺利！	{"spiritStones": 5000, "reinforceStones": 10}	f	f	\N	2026-02-21 07:18:33.781979-05	\N
9	0xa40d60613f61e8546a9e3348b1f31630443485ba	admin	管理员	🔥 欢迎来到火之文明	感谢你加入焰修世界！这是一份新手礼物，祝你修炼顺利！	{"spiritStones": 5000, "reinforceStones": 10}	f	f	\N	2026-02-21 07:18:33.785328-05	\N
10	0xbot0000000000000000000000000000000000b2	admin	管理员	🔥 欢迎来到火之文明	感谢你加入焰修世界！这是一份新手礼物，祝你修炼顺利！	{"spiritStones": 5000, "reinforceStones": 10}	f	f	\N	2026-02-21 07:18:33.787209-05	\N
11	0xbot0000000000000000000000000000000000c3	admin	管理员	🔥 欢迎来到火之文明	感谢你加入焰修世界！这是一份新手礼物，祝你修炼顺利！	{"spiritStones": 5000, "reinforceStones": 10}	f	f	\N	2026-02-21 07:18:33.7887-05	\N
13	0xadb0ecf47e175089579da5182dd7707328575909	admin	管理员	🔥 欢迎来到火之文明	感谢你加入焰修世界！这是一份新手礼物，祝你修炼顺利！	{"spiritStones": 5000, "reinforceStones": 10}	f	f	\N	2026-02-21 07:18:33.791542-05	\N
3	0xbot0000000000000000000000000000000000a1	admin	管理员	🔥 欢迎来到火之文明	感谢你加入焰修世界！这是一份新手礼物，祝你修炼顺利！	{"spiritStones": 5000, "reinforceStones": 10}	t	t	\N	2026-02-21 07:18:33.775281-05	\N
14	0xbot0000000000000000000000000000000000a1	friend	无名焰修	来自 无名焰修 的消息	回我消息	{}	f	f	\N	2026-02-21 08:22:09.491211-05	0x82e402b05f3e936b63a874788c73e1552657c4f7
16	0xbot0000000000000000000000000000000000a1	system	系统	测试空投	这是测试	{}	f	f	\N	2026-02-21 13:10:23.209258-05	\N
17	0xf55dc98d490893d3e6be354bc01cdd7ca49e3eb9	system	系统	测试空投	这是测试	{}	f	f	\N	2026-02-21 13:10:23.211302-05	\N
18	0x207e30521e0903e2a0288ed162243dc740598c06	system	系统	测试空投	这是测试	{}	f	f	\N	2026-02-21 13:10:23.212256-05	\N
19	0xbf66c656b2aff9d39f2329e5b332f5e68600fe65	system	系统	测试空投	这是测试	{}	f	f	\N	2026-02-21 13:10:23.213205-05	\N
20	0x5b5717754beb158c384281cbec4c8a4682a1e4f8	system	系统	测试空投	这是测试	{}	f	f	\N	2026-02-21 13:10:23.214151-05	\N
21	0xbot0000000000000000000000000000000000d4	system	系统	测试空投	这是测试	{}	f	f	\N	2026-02-21 13:10:23.215007-05	\N
22	0xbot0000000000000000000000000000000000e5	system	系统	测试空投	这是测试	{}	f	f	\N	2026-02-21 13:10:23.215965-05	\N
24	0xa40d60613f61e8546a9e3348b1f31630443485ba	system	系统	测试空投	这是测试	{}	f	f	\N	2026-02-21 13:10:23.21924-05	\N
25	0xbot0000000000000000000000000000000000b2	system	系统	测试空投	这是测试	{}	f	f	\N	2026-02-21 13:10:23.220333-05	\N
26	0xbot0000000000000000000000000000000000c3	system	系统	测试空投	这是测试	{}	f	f	\N	2026-02-21 13:10:23.221263-05	\N
28	0xadb0ecf47e175089579da5182dd7707328575909	system	系统	测试空投	这是测试	{}	f	f	\N	2026-02-21 13:10:23.223056-05	\N
30	0xf55dc98d490893d3e6be354bc01cdd7ca49e3eb9	system	系统	世界Boss击杀奖励	恭喜您在远古妖龙的战斗中排名第2名！奖励已发放。	{"spiritStones": 30000}	f	f	\N	2026-02-21 23:26:38.122483-05	\N
31	0xadb0ecf47e175089579da5182dd7707328575909	system	系统	世界Boss击杀奖励	恭喜您在远古妖龙的战斗中排名第3名！奖励已发放。	{"spiritStones": 20000}	f	f	\N	2026-02-21 23:26:38.122483-05	\N
32	0x82e402b05f3e936b63a874788c73e1552657c4f7	system	系统	世界Boss击杀奖励	恭喜您在远古妖龙的战斗中排名第4名！奖励已发放。	{"spiritStones": 10000}	t	t	\N	2026-02-21 23:26:38.122483-05	\N
33	0x53b07cbaefe27255578c912a9dde76bbf0f3ca16	system	系统	🔥 欢迎来到火之文明！	欢迎加入焰修世界！这是你的新手礼物，祝你修炼顺利！提示：1.先去修炼积累焰力 2.去探索获取资源 3.去焰运阁抽装备 4.记得每日签到！	{"spiritStones": 10000, "reinforceStones": 20}	f	f	\N	2026-02-22 00:55:16.556125-05	\N
35	0x602faa4d15c6df9468fbffb44618cf21834d231b	system	系统	🔥 欢迎来到火之文明！	欢迎加入焰修世界！这是你的新手礼物，祝你修炼顺利！提示：1.先去修炼积累焰力 2.去探索获取资源 3.去焰运阁抽装备 4.记得每日签到！	{"spiritStones": 10000, "reinforceStones": 20}	f	f	\N	2026-02-22 08:29:25.587963-05	\N
36	0x7c402b2d8c7d48414d5f1eb4dd6522d04992c023	system	系统	🔥 欢迎来到火之文明！	欢迎加入焰修世界！这是你的新手礼物，祝你修炼顺利！提示：1.先去修炼积累焰力 2.去探索获取资源 3.去焰运阁抽装备 4.记得每日签到！	{"spiritStones": 10000, "reinforceStones": 20}	f	f	\N	2026-02-22 12:24:16.482797-05	\N
29	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	system	系统	世界Boss击杀奖励	恭喜您在远古妖龙的战斗中排名第1名！奖励已发放。	{"spiritStones": 50000}	t	t	\N	2026-02-21 23:26:38.122483-05	\N
8	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	admin	管理员	🔥 欢迎来到火之文明	感谢你加入焰修世界！这是一份新手礼物，祝你修炼顺利！	{"spiritStones": 5000, "reinforceStones": 10}	t	t	\N	2026-02-21 07:18:33.783449-05	\N
23	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	system	系统	测试空投	这是测试	{}	t	f	\N	2026-02-21 13:10:23.217828-05	\N
34	0xc385d64735689929311621f4e81ca5b4e7830055	system	系统	🔥 欢迎来到火之文明！	欢迎加入焰修世界！这是你的新手礼物，祝你修炼顺利！提示：1.先去修炼积累焰力 2.去探索获取资源 3.去焰运阁抽装备 4.记得每日签到！	{"spiritStones": 10000, "reinforceStones": 20}	t	t	\N	2026-02-22 05:40:05.987457-05	\N
37	0x2f3a3513f2973a66e26850cc7a1baab6363d1b8f	system	系统	🔥 欢迎来到火之文明！	欢迎加入焰修世界！这是你的新手礼物，祝你修炼顺利！提示：1.先去修炼积累焰力 2.去探索获取资源 3.去焰运阁抽装备 4.记得每日签到！	{"spiritStones": 10000, "reinforceStones": 20}	t	t	\N	2026-02-23 04:31:48.196956-05	\N
38	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	system	系统	🔥 欢迎来到火之文明！	欢迎加入焰修世界！🧪 内测期间赠送100,000焰晶，祝你修炼顺利！提示：1.先去修炼积累焰力 2.去探索获取资源 3.去焰运阁抽装备 4.记得每日签到！	{"spiritStones": 110000, "reinforceStones": 20}	f	f	\N	2026-02-23 13:12:00.377429-05	\N
39	0x1dbbef8203a357b35a0da09f5ab4e1a5e19528ec	system	系统	🔥 欢迎来到火之文明！	欢迎加入焰修世界！🧪 内测期间赠送100,000焰晶，祝你修炼顺利！提示：1.先去修炼积累焰力 2.去探索获取资源 3.去焰运阁抽装备 4.记得每日签到！	{"spiritStones": 110000, "reinforceStones": 20}	f	f	\N	2026-02-24 06:20:22.674393-05	\N
\.


--
-- Data for Name: player_mounts; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.player_mounts (id, wallet, mount_id, level, exp, is_active, obtained_at) FROM stdin;
3	0xbot0000000000000000000000000000000000a1	1	1	0	f	2026-02-21 01:55:18.417926
4	0xbot0000000000000000000000000000000000a1	2	1	0	t	2026-02-21 01:55:18.449441
5	0x2f3a3513f2973a66e26850cc7a1baab6363d1b8f	1	1	0	t	2026-02-23 04:39:26.17082
2	0x82e402b05f3e936b63a874788c73e1552657c4f7	1	1	0	f	2026-02-18 15:04:36.069215
1	0x82e402b05f3e936b63a874788c73e1552657c4f7	2	1	0	t	2026-02-18 15:04:33.864543
\.


--
-- Data for Name: player_stats_snapshot; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.player_stats_snapshot (player_id, state_version, final_stats, computed_at) FROM stdin;
\.


--
-- Data for Name: player_titles; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.player_titles (id, wallet, title_id, is_active, obtained_at) FROM stdin;
14	0x2f3a3513f2973a66e26850cc7a1baab6363d1b8f	1	t	2026-02-23 04:39:37.189133
15	0x82e402b05f3e936b63a874788c73e1552657c4f7	1	f	2026-02-24 21:24:30.056929
16	0x82e402b05f3e936b63a874788c73e1552657c4f7	2	f	2026-02-24 21:24:30.058987
17	0x82e402b05f3e936b63a874788c73e1552657c4f7	3	f	2026-02-24 21:24:30.059836
18	0x82e402b05f3e936b63a874788c73e1552657c4f7	4	f	2026-02-24 21:24:30.060584
19	0x82e402b05f3e936b63a874788c73e1552657c4f7	11	f	2026-02-24 21:24:30.06133
\.


--
-- Data for Name: players; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.players (id, wallet, name, game_data, vip_level, total_recharge, spirit_stones, level, realm, combat_power, first_recharge, daily_sign_date, daily_sign_streak, created_at, updated_at, banned, state_version) FROM stdin;
4	0xf55dc98d490893d3e6be354bc01cdd7ca49e3eb9	无名修士	{"luck": 1, "name": "无名修士", "herbs": [], "items": [], "level": 1, "pills": [], "realm": "燃火期一层", "spirit": 300, "herbRate": 1, "isGMMode": false, "activePet": null, "artifacts": [], "petConfig": {"rarityMap": {"divine": {"name": "神品", "color": "#FF0000", "probability": 0.02, "essenceBonus": 50}, "mortal": {"name": "凡品", "color": "#32CD32", "probability": 0.5, "essenceBonus": 5}, "mystic": {"name": "玄品", "color": "#9932CC", "probability": 0.15, "essenceBonus": 20}, "celestial": {"name": "仙品", "color": "#FFD700", "probability": 0.08, "essenceBonus": 30}, "spiritual": {"name": "灵品", "color": "#1E90FF", "probability": 0.25, "essenceBonus": 10}}}, "isDarkMode": true, "itemsFound": 0, "petEssence": 0, "spiritRate": 1, "alchemyRate": 1, "cultivation": 0, "isNewPlayer": true, "pillRecipes": [], "pillsCrafted": 0, "spiritStones": 200000, "activeEffects": [], "pillFragments": {}, "pillsConsumed": 0, "baseAttributes": {"speed": 10, "attack": 10, "health": 100, "defense": 5}, "eventTriggered": 0, "lastOnlineTime": 1771439259224, "maxCultivation": 100, "unlockedRealms": ["燃火期一层"], "unlockedSkills": [], "artifactBonuses": {"speed": 0, "attack": 0, "health": 0, "defense": 0, "critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "healBoost": 0, "critResist": 0, "spiritRate": 1, "stunResist": 0, "combatBoost": 0, "comboResist": 0, "counterRate": 0, "dodgeResist": 0, "vampireRate": 0, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0, "cultivationRate": 1, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "cultivationRate": 1, "nameChangeCount": 0, "reinforceStones": 0, "wishlistEnabled": false, "combatAttributes": {"critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "counterRate": 0, "vampireRate": 0}, "combatResistance": {"critResist": 0, "stunResist": 0, "comboResist": 0, "dodgeResist": 0, "counterResist": 0, "vampireResist": 0}, "dungeonBossKills": 0, "dungeonTotalRuns": 0, "explorationCount": 0, "refinementStones": 0, "autoSellQualities": [], "breakthroughCount": 0, "dungeonDeathCount": 0, "dungeonDifficulty": 1, "dungeonEliteKills": 0, "dungeonTotalKills": 0, "equippedArtifacts": {"belt": null, "body": null, "feet": null, "head": null, "legs": null, "hands": null, "ring1": null, "ring2": null, "wrist": null, "weapon": null, "artifact": null, "necklace": null, "shoulder": null}, "specialAttributes": {"healBoost": 0, "combatBoost": 0, "critDamageBoost": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "unlockedLocations": ["薪火村"], "autoReleaseRarities": [], "dungeonHighestFloor": 0, "dungeonTotalRewards": 0, "unlockedPillRecipes": 0, "totalCultivationTime": 95, "completedAchievements": [], "dungeonHighestFloor_2": 0, "dungeonHighestFloor_5": 0, "selectedWishPetRarity": null, "dungeonHighestFloor_10": 0, "dungeonLastFailedFloor": 0, "dungeonHighestFloor_100": 0, "selectedWishEquipQuality": null}	0	0.00000000	200000	1	燃火期一层	225	f	\N	0	2026-02-18 13:24:30.774155	2026-02-18 13:27:39.357996	f	0
8	0x5b5717754beb158c384281cbec4c8a4682a1e4f8	无名修士	{"name": "TestPlayer", "level": 1, "realm": "练气期", "spirit": 300, "spiritStones": 200500}	0	0.00000000	200500	1	燃火期一层	0	f	2026-02-19	1	2026-02-19 13:05:24.336309	2026-02-19 13:05:24.426398	f	0
6	0x207e30521e0903e2a0288ed162243dc740598c06	无名修士	{"name": "TestPlayer", "level": 1, "realm": "练气期", "spirit": 300, "spiritStones": 200500}	0	0.00000000	200500	1	燃火期一层	0	f	2026-02-19	1	2026-02-19 12:39:18.746658	2026-02-19 12:39:18.821874	f	0
7	0xbf66c656b2aff9d39f2329e5b332f5e68600fe65	无名修士	{"name": "TestPlayer", "level": 1, "realm": "练气期", "spirit": 300, "spiritStones": 200500}	0	0.00000000	200500	1	燃火期一层	0	f	2026-02-19	1	2026-02-19 12:40:27.803176	2026-02-19 12:40:27.894942	f	0
1	0xadb0ecf47e175089579da5182dd7707328575909	无名修士	{"luck": 1, "name": "无名修士", "herbs": [], "items": [], "level": 1, "pills": [], "realm": "燃火期一层", "spirit": 300, "herbRate": 1, "isGMMode": false, "activePet": null, "artifacts": [], "petConfig": {"rarityMap": {"divine": {"name": "神品", "color": "#FF0000", "probability": 0.02, "essenceBonus": 50}, "mortal": {"name": "凡品", "color": "#32CD32", "probability": 0.5, "essenceBonus": 5}, "mystic": {"name": "玄品", "color": "#9932CC", "probability": 0.15, "essenceBonus": 20}, "celestial": {"name": "仙品", "color": "#FFD700", "probability": 0.08, "essenceBonus": 30}, "spiritual": {"name": "灵品", "color": "#1E90FF", "probability": 0.25, "essenceBonus": 10}}}, "isDarkMode": true, "itemsFound": 0, "petEssence": 0, "spiritRate": 1, "alchemyRate": 1, "cultivation": 0, "isNewPlayer": true, "pillRecipes": [], "pillsCrafted": 0, "spiritStones": 200095, "activeEffects": [], "pillFragments": {}, "pillsConsumed": 0, "baseAttributes": {"speed": 10, "attack": 10, "health": 100, "defense": 5}, "eventTriggered": 0, "lastOnlineTime": 0, "maxCultivation": 100, "unlockedRealms": ["燃火期一层"], "unlockedSkills": [], "artifactBonuses": {"speed": 0, "attack": 0, "health": 0, "defense": 0, "critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "healBoost": 0, "critResist": 0, "spiritRate": 1, "stunResist": 0, "combatBoost": 0, "comboResist": 0, "counterRate": 0, "dodgeResist": 0, "vampireRate": 0, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0, "cultivationRate": 1, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "cultivationRate": 1, "nameChangeCount": 0, "reinforceStones": 0, "wishlistEnabled": false, "combatAttributes": {"critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "counterRate": 0, "vampireRate": 0}, "combatResistance": {"critResist": 0, "stunResist": 0, "comboResist": 0, "dodgeResist": 0, "counterResist": 0, "vampireResist": 0}, "dungeonBossKills": 0, "dungeonTotalRuns": 0, "explorationCount": 0, "refinementStones": 0, "autoSellQualities": [], "breakthroughCount": 0, "dungeonDeathCount": 0, "dungeonDifficulty": 1, "dungeonEliteKills": 0, "dungeonTotalKills": 0, "equippedArtifacts": {"belt": null, "body": null, "feet": null, "head": null, "legs": null, "hands": null, "ring1": null, "ring2": null, "wrist": null, "weapon": null, "artifact": null, "necklace": null, "shoulder": null}, "specialAttributes": {"healBoost": 0, "combatBoost": 0, "critDamageBoost": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "unlockedLocations": ["薪火村"], "autoReleaseRarities": [], "dungeonHighestFloor": 0, "dungeonTotalRewards": 0, "unlockedPillRecipes": 0, "totalCultivationTime": 0, "completedAchievements": [], "dungeonHighestFloor_2": 0, "dungeonHighestFloor_5": 0, "selectedWishPetRarity": null, "dungeonHighestFloor_10": 0, "dungeonLastFailedFloor": 0, "dungeonHighestFloor_100": 0, "selectedWishEquipQuality": null}	0	2.00000000	200095	1	燃火期一层	225	t	2026-02-18	1	2026-02-17 14:45:23.062581	2026-02-18 12:59:22.960838	f	0
13	0xbot0000000000000000000000000000000000e5	焰灵·初修	{"name": "妖修·九尾", "items": [{"id": 1771671531638.7888, "name": "灵猫", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 5, "strength": 6, "constitution": 2, "intelligence": 6}, "experience": 0, "description": "敏捷的小型焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 11, "health": 103, "defense": 8, "critRate": 0.07, "stunRate": 0.09, "comboRate": 0.08, "dodgeRate": 0.06, "healBoost": 0.08, "critResist": 0.08, "stunResist": 0.08, "combatBoost": 0.08, "comboResist": 0.06, "counterRate": 0.07, "dodgeResist": 0.09, "vampireRate": 0.08, "counterResist": 0.05, "vampireResist": 0.05, "critDamageBoost": 0.08, "resistanceBoost": 0.09, "critDamageReduce": 0.05, "finalDamageBoost": 0.06, "finalDamageReduce": 0.06}}, {"id": 1771671531805.5637, "name": "草兔", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 2, "strength": 6, "constitution": 7, "intelligence": 9}, "experience": 0, "description": "温顺的兔类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 9, "attack": 11, "health": 104, "defense": 7, "critRate": 0.07, "stunRate": 0.07, "comboRate": 0.1, "dodgeRate": 0.06, "healBoost": 0.09, "critResist": 0.08, "stunResist": 0.06, "combatBoost": 0.08, "comboResist": 0.06, "counterRate": 0.08, "dodgeResist": 0.09, "vampireRate": 0.06, "counterResist": 0.06, "vampireResist": 0.09, "critDamageBoost": 0.06, "resistanceBoost": 0.07, "critDamageReduce": 0.07, "finalDamageBoost": 0.08, "finalDamageReduce": 0.08}}, {"id": 1771671531894.8552, "name": "火凤凰", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 1, "strength": 6, "constitution": 7, "intelligence": 3}, "experience": 0, "description": "浴火重生的永恒之鸟", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 26, "attack": 32, "health": 348, "defense": 24, "critRate": 0.08, "stunRate": 0.15, "comboRate": 0.16, "dodgeRate": 0.13, "healBoost": 0.1, "critResist": 0.13, "stunResist": 0.14, "combatBoost": 0.08, "comboResist": 0.15, "counterRate": 0.13, "dodgeResist": 0.14, "vampireRate": 0.14, "counterResist": 0.12, "vampireResist": 0.09, "critDamageBoost": 0.15, "resistanceBoost": 0.1, "critDamageReduce": 0.14, "finalDamageBoost": 0.11, "finalDamageReduce": 0.11}}, {"id": 1771671531976.277, "name": "风隼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 2, "strength": 5, "constitution": 9, "intelligence": 3}, "experience": 0, "description": "速度极快的飞行焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 18, "attack": 28, "health": 237, "defense": 15, "critRate": 0.09, "stunRate": 0.07, "comboRate": 0.11, "dodgeRate": 0.08, "healBoost": 0.12, "critResist": 0.13, "stunResist": 0.13, "combatBoost": 0.11, "comboResist": 0.07, "counterRate": 0.09, "dodgeResist": 0.08, "vampireRate": 0.13, "counterResist": 0.07, "vampireResist": 0.13, "critDamageBoost": 0.09, "resistanceBoost": 0.1, "critDamageReduce": 0.13, "finalDamageBoost": 0.13, "finalDamageReduce": 0.12}}, {"id": 1771671550219.3088, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 10, "strength": 9, "constitution": 8, "intelligence": 5}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 15, "health": 105, "defense": 7, "critRate": 0.09, "stunRate": 0.09, "comboRate": 0.07, "dodgeRate": 0.06, "healBoost": 0.05, "critResist": 0.1, "stunResist": 0.06, "combatBoost": 0.08, "comboResist": 0.06, "counterRate": 0.06, "dodgeResist": 0.09, "vampireRate": 0.05, "counterResist": 0.1, "vampireResist": 0.06, "critDamageBoost": 0.06, "resistanceBoost": 0.07, "critDamageReduce": 0.08, "finalDamageBoost": 0.08, "finalDamageReduce": 0.07}}, {"id": 1771671550219.8062, "name": "风隼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 5, "strength": 7, "constitution": 9, "intelligence": 3}, "experience": 0, "description": "速度极快的飞行焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 16, "attack": 30, "health": 231, "defense": 14, "critRate": 0.14, "stunRate": 0.07, "comboRate": 0.08, "dodgeRate": 0.08, "healBoost": 0.1, "critResist": 0.09, "stunResist": 0.1, "combatBoost": 0.09, "comboResist": 0.13, "counterRate": 0.12, "dodgeResist": 0.1, "vampireRate": 0.13, "counterResist": 0.09, "vampireResist": 0.11, "critDamageBoost": 0.11, "resistanceBoost": 0.12, "critDamageReduce": 0.08, "finalDamageBoost": 0.14, "finalDamageReduce": 0.07}}, {"id": 1771671550219.9656, "name": "云豹", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 3, "strength": 6, "constitution": 4, "intelligence": 8}, "experience": 0, "description": "敏捷的猎手", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 16, "attack": 26, "health": 208, "defense": 15, "critRate": 0.07, "stunRate": 0.13, "comboRate": 0.1, "dodgeRate": 0.13, "healBoost": 0.12, "critResist": 0.09, "stunResist": 0.14, "combatBoost": 0.13, "comboResist": 0.12, "counterRate": 0.11, "dodgeResist": 0.08, "vampireRate": 0.11, "counterResist": 0.13, "vampireResist": 0.1, "critDamageBoost": 0.14, "resistanceBoost": 0.1, "critDamageReduce": 0.12, "finalDamageBoost": 0.12, "finalDamageReduce": 0.08}}, {"id": 1771671550219.0532, "name": "冰狼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 8, "strength": 10, "constitution": 7, "intelligence": 9}, "experience": 0, "description": "冰原霸主", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 26, "attack": 31, "health": 323, "defense": 22, "critRate": 0.09, "stunRate": 0.1, "comboRate": 0.1, "dodgeRate": 0.16, "healBoost": 0.12, "critResist": 0.09, "stunResist": 0.09, "combatBoost": 0.11, "comboResist": 0.14, "counterRate": 0.16, "dodgeResist": 0.11, "vampireRate": 0.11, "counterResist": 0.13, "vampireResist": 0.08, "critDamageBoost": 0.14, "resistanceBoost": 0.1, "critDamageReduce": 0.14, "finalDamageBoost": 0.14, "finalDamageReduce": 0.11}}, {"id": 1771671550219.9016, "name": "冰狼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 6, "strength": 9, "constitution": 1, "intelligence": 6}, "experience": 0, "description": "冰原霸主", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 18, "attack": 38, "health": 307, "defense": 17, "critRate": 0.13, "stunRate": 0.16, "comboRate": 0.13, "dodgeRate": 0.11, "healBoost": 0.13, "critResist": 0.08, "stunResist": 0.1, "combatBoost": 0.1, "comboResist": 0.15, "counterRate": 0.15, "dodgeResist": 0.13, "vampireRate": 0.12, "counterResist": 0.14, "vampireResist": 0.14, "critDamageBoost": 0.11, "resistanceBoost": 0.15, "critDamageReduce": 0.09, "finalDamageBoost": 0.11, "finalDamageReduce": 0.14}}, {"id": 1771671550248.2969, "name": "玄龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 2, "strength": 3, "constitution": 5, "intelligence": 2}, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 17, "attack": 25, "health": 217, "defense": 14, "critRate": 0.12, "stunRate": 0.1, "comboRate": 0.09, "dodgeRate": 0.13, "healBoost": 0.11, "critResist": 0.08, "stunResist": 0.12, "combatBoost": 0.11, "comboResist": 0.09, "counterRate": 0.09, "dodgeResist": 0.12, "vampireRate": 0.11, "counterResist": 0.11, "vampireResist": 0.11, "critDamageBoost": 0.13, "resistanceBoost": 0.1, "critDamageReduce": 0.12, "finalDamageBoost": 0.1, "finalDamageReduce": 0.1}}, {"id": 1771671550387.0337, "name": "岩龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 7, "strength": 4, "constitution": 6, "intelligence": 9}, "experience": 0, "description": "坚不可摧的守护者", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 18, "attack": 33, "health": 315, "defense": 21, "critRate": 0.13, "stunRate": 0.14, "comboRate": 0.15, "dodgeRate": 0.09, "healBoost": 0.08, "critResist": 0.1, "stunResist": 0.11, "combatBoost": 0.08, "comboResist": 0.12, "counterRate": 0.13, "dodgeResist": 0.1, "vampireRate": 0.11, "counterResist": 0.15, "vampireResist": 0.16, "critDamageBoost": 0.13, "resistanceBoost": 0.13, "critDamageReduce": 0.13, "finalDamageBoost": 0.09, "finalDamageReduce": 0.11}}, {"id": 1771671550387.9053, "name": "火鼠", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 10, "strength": 4, "constitution": 10, "intelligence": 2}, "experience": 0, "description": "活泼的啮齿类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 12, "health": 115, "defense": 6, "critRate": 0.08, "stunRate": 0.09, "comboRate": 0.08, "dodgeRate": 0.09, "healBoost": 0.05, "critResist": 0.09, "stunResist": 0.05, "combatBoost": 0.1, "comboResist": 0.09, "counterRate": 0.07, "dodgeResist": 0.1, "vampireRate": 0.09, "counterResist": 0.09, "vampireResist": 0.09, "critDamageBoost": 0.09, "resistanceBoost": 0.1, "critDamageReduce": 0.07, "finalDamageBoost": 0.07, "finalDamageReduce": 0.1}}, {"id": 1771671550387.261, "name": "灵猫", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 5, "strength": 8, "constitution": 3, "intelligence": 4}, "experience": 0, "description": "敏捷的小型焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 6, "attack": 12, "health": 105, "defense": 6, "critRate": 0.08, "stunRate": 0.06, "comboRate": 0.07, "dodgeRate": 0.06, "healBoost": 0.06, "critResist": 0.1, "stunResist": 0.07, "combatBoost": 0.09, "comboResist": 0.07, "counterRate": 0.07, "dodgeResist": 0.06, "vampireRate": 0.05, "counterResist": 0.07, "vampireResist": 0.07, "critDamageBoost": 0.09, "resistanceBoost": 0.09, "critDamageReduce": 0.05, "finalDamageBoost": 0.07, "finalDamageReduce": 0.08}}, {"id": 1771671550387.1687, "name": "玄龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 9, "strength": 10, "constitution": 10, "intelligence": 4}, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 18, "attack": 27, "health": 239, "defense": 14, "critRate": 0.13, "stunRate": 0.11, "comboRate": 0.09, "dodgeRate": 0.11, "healBoost": 0.12, "critResist": 0.13, "stunResist": 0.08, "combatBoost": 0.08, "comboResist": 0.08, "counterRate": 0.12, "dodgeResist": 0.08, "vampireRate": 0.11, "counterResist": 0.1, "vampireResist": 0.14, "critDamageBoost": 0.12, "resistanceBoost": 0.13, "critDamageReduce": 0.1, "finalDamageBoost": 0.12, "finalDamageReduce": 0.08}}, {"id": 1771671550387.85, "name": "草兔", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 8, "constitution": 10, "intelligence": 3}, "experience": 0, "description": "温顺的兔类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 6, "attack": 12, "health": 108, "defense": 7, "critRate": 0.07, "stunRate": 0.07, "comboRate": 0.08, "dodgeRate": 0.06, "healBoost": 0.07, "critResist": 0.07, "stunResist": 0.09, "combatBoost": 0.05, "comboResist": 0.07, "counterRate": 0.05, "dodgeResist": 0.05, "vampireRate": 0.07, "counterResist": 0.07, "vampireResist": 0.07, "critDamageBoost": 0.06, "resistanceBoost": 0.08, "critDamageReduce": 0.06, "finalDamageBoost": 0.07, "finalDamageReduce": 0.06}}, {"id": 1771671550387.9182, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 6, "strength": 9, "constitution": 9, "intelligence": 1}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 15, "health": 110, "defense": 5, "critRate": 0.06, "stunRate": 0.07, "comboRate": 0.09, "dodgeRate": 0.08, "healBoost": 0.07, "critResist": 0.09, "stunResist": 0.09, "combatBoost": 0.06, "comboResist": 0.06, "counterRate": 0.09, "dodgeResist": 0.09, "vampireRate": 0.08, "counterResist": 0.07, "vampireResist": 0.07, "critDamageBoost": 0.05, "resistanceBoost": 0.05, "critDamageReduce": 0.08, "finalDamageBoost": 0.08, "finalDamageReduce": 0.09}}, {"id": 1771671550387.3625, "name": "火凤凰", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 9, "strength": 4, "constitution": 6, "intelligence": 7}, "experience": 0, "description": "浴火重生的永恒之鸟", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 24, "attack": 43, "health": 314, "defense": 19, "critRate": 0.15, "stunRate": 0.14, "comboRate": 0.14, "dodgeRate": 0.13, "healBoost": 0.1, "critResist": 0.16, "stunResist": 0.15, "combatBoost": 0.15, "comboResist": 0.09, "counterRate": 0.09, "dodgeResist": 0.16, "vampireRate": 0.1, "counterResist": 0.12, "vampireResist": 0.11, "critDamageBoost": 0.13, "resistanceBoost": 0.12, "critDamageReduce": 0.14, "finalDamageBoost": 0.15, "finalDamageReduce": 0.09}}, {"id": 1771671550387.9214, "name": "岩龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 5, "strength": 1, "constitution": 1, "intelligence": 6}, "experience": 0, "description": "坚不可摧的守护者", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 19, "attack": 38, "health": 303, "defense": 16, "critRate": 0.16, "stunRate": 0.14, "comboRate": 0.15, "dodgeRate": 0.14, "healBoost": 0.09, "critResist": 0.14, "stunResist": 0.16, "combatBoost": 0.1, "comboResist": 0.1, "counterRate": 0.09, "dodgeResist": 0.09, "vampireRate": 0.15, "counterResist": 0.15, "vampireResist": 0.15, "critDamageBoost": 0.09, "resistanceBoost": 0.09, "critDamageReduce": 0.13, "finalDamageBoost": 0.14, "finalDamageReduce": 0.1}}, {"id": 1771671550387.2554, "name": "云豹", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 3, "strength": 4, "constitution": 4, "intelligence": 8}, "experience": 0, "description": "敏捷的猎手", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 13, "attack": 28, "health": 237, "defense": 15, "critRate": 0.12, "stunRate": 0.12, "comboRate": 0.14, "dodgeRate": 0.1, "healBoost": 0.09, "critResist": 0.1, "stunResist": 0.13, "combatBoost": 0.1, "comboResist": 0.14, "counterRate": 0.1, "dodgeResist": 0.12, "vampireRate": 0.1, "counterResist": 0.12, "vampireResist": 0.08, "critDamageBoost": 0.08, "resistanceBoost": 0.08, "critDamageReduce": 0.11, "finalDamageBoost": 0.14, "finalDamageReduce": 0.11}}, {"id": 1771671550387.193, "name": "火鼠", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 1, "strength": 9, "constitution": 1, "intelligence": 4}, "experience": 0, "description": "活泼的啮齿类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 12, "health": 112, "defense": 7, "critRate": 0.05, "stunRate": 0.08, "comboRate": 0.06, "dodgeRate": 0.06, "healBoost": 0.06, "critResist": 0.07, "stunResist": 0.06, "combatBoost": 0.05, "comboResist": 0.07, "counterRate": 0.08, "dodgeResist": 0.07, "vampireRate": 0.08, "counterResist": 0.05, "vampireResist": 0.08, "critDamageBoost": 0.08, "resistanceBoost": 0.07, "critDamageReduce": 0.09, "finalDamageBoost": 0.07, "finalDamageReduce": 0.1}}, {"id": 1771671550387.5693, "name": "灵猫", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 5, "strength": 6, "constitution": 7, "intelligence": 1}, "experience": 0, "description": "敏捷的小型焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 13, "health": 113, "defense": 8, "critRate": 0.09, "stunRate": 0.09, "comboRate": 0.07, "dodgeRate": 0.09, "healBoost": 0.06, "critResist": 0.09, "stunResist": 0.07, "combatBoost": 0.07, "comboResist": 0.1, "counterRate": 0.06, "dodgeResist": 0.1, "vampireRate": 0.06, "counterResist": 0.07, "vampireResist": 0.05, "critDamageBoost": 0.09, "resistanceBoost": 0.07, "critDamageReduce": 0.07, "finalDamageBoost": 0.08, "finalDamageReduce": 0.1}}, {"id": 1771671550387.141, "name": "玄龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 8, "strength": 9, "constitution": 10, "intelligence": 7}, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 12, "attack": 27, "health": 224, "defense": 12, "critRate": 0.11, "stunRate": 0.13, "comboRate": 0.09, "dodgeRate": 0.14, "healBoost": 0.07, "critResist": 0.1, "stunResist": 0.13, "combatBoost": 0.13, "comboResist": 0.1, "counterRate": 0.13, "dodgeResist": 0.12, "vampireRate": 0.07, "counterResist": 0.14, "vampireResist": 0.08, "critDamageBoost": 0.08, "resistanceBoost": 0.1, "critDamageReduce": 0.08, "finalDamageBoost": 0.11, "finalDamageReduce": 0.13}}, {"id": 1771671550387.0647, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 1, "constitution": 5, "intelligence": 7}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 9, "attack": 10, "health": 114, "defense": 7, "critRate": 0.07, "stunRate": 0.08, "comboRate": 0.1, "dodgeRate": 0.09, "healBoost": 0.07, "critResist": 0.08, "stunResist": 0.06, "combatBoost": 0.06, "comboResist": 0.06, "counterRate": 0.07, "dodgeResist": 0.08, "vampireRate": 0.06, "counterResist": 0.07, "vampireResist": 0.06, "critDamageBoost": 0.08, "resistanceBoost": 0.07, "critDamageReduce": 0.05, "finalDamageBoost": 0.1, "finalDamageReduce": 0.06}}, {"id": 1771671550387.1443, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 5, "strength": 7, "constitution": 7, "intelligence": 4}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 13, "health": 113, "defense": 8, "critRate": 0.1, "stunRate": 0.1, "comboRate": 0.08, "dodgeRate": 0.08, "healBoost": 0.05, "critResist": 0.06, "stunResist": 0.05, "combatBoost": 0.06, "comboResist": 0.06, "counterRate": 0.07, "dodgeResist": 0.07, "vampireRate": 0.08, "counterResist": 0.1, "vampireResist": 0.09, "critDamageBoost": 0.1, "resistanceBoost": 0.1, "critDamageReduce": 0.06, "finalDamageBoost": 0.07, "finalDamageReduce": 0.05}}, {"id": 1771671550387.5322, "name": "螭吻", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "celestial", "quality": {"agility": 8, "strength": 6, "constitution": 5, "intelligence": 8}, "experience": 0, "description": "龙之九子，形似鱼，能吞火，常立于屋脊", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 33, "attack": 51, "health": 409, "defense": 29, "critRate": 0.15, "stunRate": 0.11, "comboRate": 0.15, "dodgeRate": 0.12, "healBoost": 0.18, "critResist": 0.17, "stunResist": 0.15, "combatBoost": 0.14, "comboResist": 0.17, "counterRate": 0.18, "dodgeResist": 0.17, "vampireRate": 0.18, "counterResist": 0.16, "vampireResist": 0.14, "critDamageBoost": 0.15, "resistanceBoost": 0.1, "critDamageReduce": 0.12, "finalDamageBoost": 0.18, "finalDamageReduce": 0.16}}, {"id": 1771671550387.017, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 9, "strength": 3, "constitution": 8, "intelligence": 3}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 15, "health": 100, "defense": 8, "critRate": 0.1, "stunRate": 0.06, "comboRate": 0.09, "dodgeRate": 0.09, "healBoost": 0.07, "critResist": 0.1, "stunResist": 0.06, "combatBoost": 0.1, "comboResist": 0.05, "counterRate": 0.08, "dodgeResist": 0.07, "vampireRate": 0.05, "counterResist": 0.1, "vampireResist": 0.09, "critDamageBoost": 0.07, "resistanceBoost": 0.08, "critDamageReduce": 0.07, "finalDamageBoost": 0.09, "finalDamageReduce": 0.07}}, {"id": 1771671550387.9111, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 2, "constitution": 3, "intelligence": 7}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 15, "health": 101, "defense": 8, "critRate": 0.07, "stunRate": 0.07, "comboRate": 0.08, "dodgeRate": 0.06, "healBoost": 0.08, "critResist": 0.07, "stunResist": 0.05, "combatBoost": 0.06, "comboResist": 0.1, "counterRate": 0.08, "dodgeResist": 0.08, "vampireRate": 0.09, "counterResist": 0.05, "vampireResist": 0.08, "critDamageBoost": 0.09, "resistanceBoost": 0.1, "critDamageReduce": 0.1, "finalDamageBoost": 0.08, "finalDamageReduce": 0.08}}, {"id": 1771671550387.4773, "name": "火鼠", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 3, "constitution": 10, "intelligence": 5}, "experience": 0, "description": "活泼的啮齿类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 10, "health": 108, "defense": 6, "critRate": 0.08, "stunRate": 0.07, "comboRate": 0.06, "dodgeRate": 0.07, "healBoost": 0.06, "critResist": 0.09, "stunResist": 0.06, "combatBoost": 0.05, "comboResist": 0.09, "counterRate": 0.06, "dodgeResist": 0.07, "vampireRate": 0.07, "counterResist": 0.07, "vampireResist": 0.08, "critDamageBoost": 0.06, "resistanceBoost": 0.07, "critDamageReduce": 0.06, "finalDamageBoost": 0.08, "finalDamageReduce": 0.07}}, {"id": 1771671550387.2922, "name": "冰狼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 10, "strength": 1, "constitution": 6, "intelligence": 7}, "experience": 0, "description": "冰原霸主", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 26, "attack": 44, "health": 328, "defense": 22, "critRate": 0.11, "stunRate": 0.14, "comboRate": 0.14, "dodgeRate": 0.11, "healBoost": 0.13, "critResist": 0.16, "stunResist": 0.15, "combatBoost": 0.13, "comboResist": 0.13, "counterRate": 0.08, "dodgeResist": 0.11, "vampireRate": 0.15, "counterResist": 0.16, "vampireResist": 0.15, "critDamageBoost": 0.13, "resistanceBoost": 0.1, "critDamageReduce": 0.11, "finalDamageBoost": 0.15, "finalDamageReduce": 0.15}}, {"id": 1771671550387.8171, "name": "玄龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 10, "strength": 5, "constitution": 7, "intelligence": 1}, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 14, "attack": 22, "health": 221, "defense": 15, "critRate": 0.08, "stunRate": 0.08, "comboRate": 0.13, "dodgeRate": 0.1, "healBoost": 0.11, "critResist": 0.09, "stunResist": 0.07, "combatBoost": 0.1, "comboResist": 0.11, "counterRate": 0.1, "dodgeResist": 0.12, "vampireRate": 0.08, "counterResist": 0.09, "vampireResist": 0.1, "critDamageBoost": 0.11, "resistanceBoost": 0.09, "critDamageReduce": 0.13, "finalDamageBoost": 0.14, "finalDamageReduce": 0.12}}, {"id": 1771671550387.6243, "name": "火鼠", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 5, "strength": 8, "constitution": 10, "intelligence": 6}, "experience": 0, "description": "活泼的啮齿类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 14, "health": 118, "defense": 8, "critRate": 0.1, "stunRate": 0.1, "comboRate": 0.06, "dodgeRate": 0.08, "healBoost": 0.05, "critResist": 0.06, "stunResist": 0.06, "combatBoost": 0.05, "comboResist": 0.07, "counterRate": 0.07, "dodgeResist": 0.09, "vampireRate": 0.08, "counterResist": 0.1, "vampireResist": 0.09, "critDamageBoost": 0.06, "resistanceBoost": 0.07, "critDamageReduce": 0.07, "finalDamageBoost": 0.07, "finalDamageReduce": 0.09}}, {"id": 1771671550387.2207, "name": "岩龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 1, "strength": 3, "constitution": 5, "intelligence": 4}, "experience": 0, "description": "坚不可摧的守护者", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 26, "attack": 39, "health": 317, "defense": 19, "critRate": 0.09, "stunRate": 0.1, "comboRate": 0.16, "dodgeRate": 0.12, "healBoost": 0.11, "critResist": 0.11, "stunResist": 0.09, "combatBoost": 0.12, "comboResist": 0.09, "counterRate": 0.08, "dodgeResist": 0.13, "vampireRate": 0.16, "counterResist": 0.14, "vampireResist": 0.13, "critDamageBoost": 0.14, "resistanceBoost": 0.14, "critDamageReduce": 0.09, "finalDamageBoost": 0.11, "finalDamageReduce": 0.13}}, {"id": 1771671550387.3772, "name": "云豹", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 7, "strength": 2, "constitution": 8, "intelligence": 3}, "experience": 0, "description": "敏捷的猎手", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 12, "attack": 22, "health": 236, "defense": 14, "critRate": 0.11, "stunRate": 0.07, "comboRate": 0.07, "dodgeRate": 0.14, "healBoost": 0.12, "critResist": 0.07, "stunResist": 0.1, "combatBoost": 0.14, "comboResist": 0.1, "counterRate": 0.09, "dodgeResist": 0.13, "vampireRate": 0.08, "counterResist": 0.09, "vampireResist": 0.11, "critDamageBoost": 0.07, "resistanceBoost": 0.11, "critDamageReduce": 0.13, "finalDamageBoost": 0.12, "finalDamageReduce": 0.11}}, {"id": 1771671550387.2954, "name": "负屃", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "celestial", "quality": {"agility": 9, "strength": 3, "constitution": 2, "intelligence": 5}, "experience": 0, "description": "龙之八子，形似龙，雅好诗文，常盘于碑顶", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 36, "attack": 59, "health": 427, "defense": 22, "critRate": 0.18, "stunRate": 0.1, "comboRate": 0.18, "dodgeRate": 0.11, "healBoost": 0.11, "critResist": 0.14, "stunResist": 0.12, "combatBoost": 0.14, "comboResist": 0.11, "counterRate": 0.11, "dodgeResist": 0.15, "vampireRate": 0.18, "counterResist": 0.11, "vampireResist": 0.13, "critDamageBoost": 0.15, "resistanceBoost": 0.18, "critDamageReduce": 0.11, "finalDamageBoost": 0.12, "finalDamageReduce": 0.16}}, {"id": 1771671550387.5205, "name": "云豹", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 6, "strength": 1, "constitution": 2, "intelligence": 1}, "experience": 0, "description": "敏捷的猎手", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 18, "attack": 25, "health": 216, "defense": 12, "critRate": 0.09, "stunRate": 0.11, "comboRate": 0.09, "dodgeRate": 0.12, "healBoost": 0.11, "critResist": 0.07, "stunResist": 0.13, "combatBoost": 0.12, "comboResist": 0.11, "counterRate": 0.12, "dodgeResist": 0.11, "vampireRate": 0.13, "counterResist": 0.08, "vampireResist": 0.11, "critDamageBoost": 0.09, "resistanceBoost": 0.12, "critDamageReduce": 0.1, "finalDamageBoost": 0.11, "finalDamageReduce": 0.12}}, {"id": 1771671550387.4868, "name": "草兔", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 9, "strength": 1, "constitution": 6, "intelligence": 10}, "experience": 0, "description": "温顺的兔类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 9, "attack": 15, "health": 116, "defense": 6, "critRate": 0.1, "stunRate": 0.07, "comboRate": 0.1, "dodgeRate": 0.07, "healBoost": 0.09, "critResist": 0.06, "stunResist": 0.07, "combatBoost": 0.07, "comboResist": 0.06, "counterRate": 0.09, "dodgeResist": 0.08, "vampireRate": 0.07, "counterResist": 0.08, "vampireResist": 0.06, "critDamageBoost": 0.07, "resistanceBoost": 0.08, "critDamageReduce": 0.06, "finalDamageBoost": 0.09, "finalDamageReduce": 0.07}}, {"id": 1771671550387.4758, "name": "云豹", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 9, "strength": 10, "constitution": 1, "intelligence": 1}, "experience": 0, "description": "敏捷的猎手", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 15, "attack": 22, "health": 217, "defense": 14, "critRate": 0.1, "stunRate": 0.08, "comboRate": 0.13, "dodgeRate": 0.14, "healBoost": 0.14, "critResist": 0.1, "stunResist": 0.09, "combatBoost": 0.09, "comboResist": 0.1, "counterRate": 0.07, "dodgeResist": 0.1, "vampireRate": 0.07, "counterResist": 0.07, "vampireResist": 0.11, "critDamageBoost": 0.08, "resistanceBoost": 0.07, "critDamageReduce": 0.08, "finalDamageBoost": 0.11, "finalDamageReduce": 0.08}}, {"id": 1771671550387.8193, "name": "灵猫", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 7, "constitution": 3, "intelligence": 9}, "experience": 0, "description": "敏捷的小型焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 6, "attack": 15, "health": 105, "defense": 8, "critRate": 0.09, "stunRate": 0.09, "comboRate": 0.1, "dodgeRate": 0.09, "healBoost": 0.07, "critResist": 0.09, "stunResist": 0.09, "combatBoost": 0.07, "comboResist": 0.07, "counterRate": 0.09, "dodgeResist": 0.09, "vampireRate": 0.05, "counterResist": 0.09, "vampireResist": 0.09, "critDamageBoost": 0.07, "resistanceBoost": 0.07, "critDamageReduce": 0.08, "finalDamageBoost": 0.05, "finalDamageReduce": 0.08}}, {"id": 1771671550387.5312, "name": "玄龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 1, "strength": 1, "constitution": 8, "intelligence": 4}, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 14, "attack": 21, "health": 219, "defense": 15, "critRate": 0.12, "stunRate": 0.08, "comboRate": 0.13, "dodgeRate": 0.1, "healBoost": 0.08, "critResist": 0.13, "stunResist": 0.13, "combatBoost": 0.12, "comboResist": 0.1, "counterRate": 0.1, "dodgeResist": 0.1, "vampireRate": 0.11, "counterResist": 0.13, "vampireResist": 0.08, "critDamageBoost": 0.12, "resistanceBoost": 0.09, "critDamageReduce": 0.11, "finalDamageBoost": 0.1, "finalDamageReduce": 0.1}}, {"id": 1771671550387.9797, "name": "火鼠", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 3, "strength": 3, "constitution": 3, "intelligence": 6}, "experience": 0, "description": "活泼的啮齿类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 9, "attack": 11, "health": 107, "defense": 7, "critRate": 0.08, "stunRate": 0.1, "comboRate": 0.07, "dodgeRate": 0.07, "healBoost": 0.08, "critResist": 0.05, "stunResist": 0.08, "combatBoost": 0.07, "comboResist": 0.06, "counterRate": 0.05, "dodgeResist": 0.06, "vampireRate": 0.1, "counterResist": 0.09, "vampireResist": 0.09, "critDamageBoost": 0.06, "resistanceBoost": 0.07, "critDamageReduce": 0.1, "finalDamageBoost": 0.08, "finalDamageReduce": 0.07}}, {"id": 1771671550387.976, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 10, "strength": 3, "constitution": 7, "intelligence": 10}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 13, "health": 119, "defense": 8, "critRate": 0.09, "stunRate": 0.06, "comboRate": 0.09, "dodgeRate": 0.08, "healBoost": 0.09, "critResist": 0.07, "stunResist": 0.07, "combatBoost": 0.09, "comboResist": 0.08, "counterRate": 0.07, "dodgeResist": 0.06, "vampireRate": 0.08, "counterResist": 0.08, "vampireResist": 0.06, "critDamageBoost": 0.07, "resistanceBoost": 0.07, "critDamageReduce": 0.07, "finalDamageBoost": 0.06, "finalDamageReduce": 0.07}}, {"id": 1771671550387.2988, "name": "雷鹰", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 9, "strength": 2, "constitution": 2, "intelligence": 1}, "experience": 0, "description": "雷电的猛禽", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 25, "attack": 37, "health": 327, "defense": 17, "critRate": 0.08, "stunRate": 0.08, "comboRate": 0.15, "dodgeRate": 0.11, "healBoost": 0.12, "critResist": 0.14, "stunResist": 0.09, "combatBoost": 0.13, "comboResist": 0.15, "counterRate": 0.09, "dodgeResist": 0.08, "vampireRate": 0.15, "counterResist": 0.13, "vampireResist": 0.09, "critDamageBoost": 0.11, "resistanceBoost": 0.15, "critDamageReduce": 0.08, "finalDamageBoost": 0.1, "finalDamageReduce": 0.11}}, {"id": 1771671550387.8296, "name": "草兔", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 2, "strength": 4, "constitution": 3, "intelligence": 6}, "experience": 0, "description": "温顺的兔类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 12, "health": 105, "defense": 6, "critRate": 0.1, "stunRate": 0.06, "comboRate": 0.09, "dodgeRate": 0.08, "healBoost": 0.08, "critResist": 0.06, "stunResist": 0.1, "combatBoost": 0.06, "comboResist": 0.07, "counterRate": 0.08, "dodgeResist": 0.05, "vampireRate": 0.09, "counterResist": 0.1, "vampireResist": 0.06, "critDamageBoost": 0.08, "resistanceBoost": 0.05, "critDamageReduce": 0.06, "finalDamageBoost": 0.05, "finalDamageReduce": 0.06}}, {"id": 1771671550387.867, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 3, "strength": 2, "constitution": 5, "intelligence": 5}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 9, "attack": 15, "health": 117, "defense": 6, "critRate": 0.09, "stunRate": 0.07, "comboRate": 0.07, "dodgeRate": 0.07, "healBoost": 0.05, "critResist": 0.1, "stunResist": 0.07, "combatBoost": 0.05, "comboResist": 0.09, "counterRate": 0.08, "dodgeResist": 0.06, "vampireRate": 0.06, "counterResist": 0.05, "vampireResist": 0.08, "critDamageBoost": 0.07, "resistanceBoost": 0.09, "critDamageReduce": 0.07, "finalDamageBoost": 0.06, "finalDamageReduce": 0.08}}, {"id": 1771671550387.666, "name": "草兔", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 3, "constitution": 5, "intelligence": 4}, "experience": 0, "description": "温顺的兔类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 12, "health": 103, "defense": 8, "critRate": 0.05, "stunRate": 0.09, "comboRate": 0.1, "dodgeRate": 0.07, "healBoost": 0.07, "critResist": 0.06, "stunResist": 0.06, "combatBoost": 0.08, "comboResist": 0.09, "counterRate": 0.08, "dodgeResist": 0.07, "vampireRate": 0.06, "counterResist": 0.07, "vampireResist": 0.08, "critDamageBoost": 0.09, "resistanceBoost": 0.08, "critDamageReduce": 0.1, "finalDamageBoost": 0.07, "finalDamageReduce": 0.1}}, {"id": 1771671550387.2104, "name": "地甲", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 8, "strength": 4, "constitution": 8, "intelligence": 1}, "experience": 0, "description": "坚固的大地守护者", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 14, "attack": 28, "health": 230, "defense": 13, "critRate": 0.13, "stunRate": 0.12, "comboRate": 0.09, "dodgeRate": 0.11, "healBoost": 0.12, "critResist": 0.08, "stunResist": 0.1, "combatBoost": 0.11, "comboResist": 0.12, "counterRate": 0.08, "dodgeResist": 0.11, "vampireRate": 0.08, "counterResist": 0.11, "vampireResist": 0.07, "critDamageBoost": 0.12, "resistanceBoost": 0.07, "critDamageReduce": 0.08, "finalDamageBoost": 0.13, "finalDamageReduce": 0.1}}, {"id": 1771671550387.0518, "name": "星宝焰器·初", "slot": "artifact", "type": "artifact", "level": 13, "stats": {"attack": 1, "critRate": 0.04, "comboRate": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "artifact", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 13}, {"id": 1771671550387.3079, "name": "云雾裤子", "slot": "legs", "type": "legs", "level": 6, "stats": {"speed": 14, "defense": 10, "dodgeRate": 0.02}, "quality": "common", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 6}, {"id": 1771671550387.938, "name": "玄圣焰心链", "slot": "necklace", "type": "necklace", "level": 7, "stats": {"health": 123, "healBoost": 0.04, "spiritRate": 0.04}, "quality": "common", "category": "equipment", "equipType": "necklace", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 7}, {"id": 1771671550387.8188, "name": "赤金手套·真", "slot": "hands", "type": "hands", "level": 4, "stats": {"attack": 18, "critRate": 0.02, "comboRate": 0.03}, "quality": "rare", "category": "equipment", "equipType": "hands", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 4}, {"id": 1771671550387.6348, "name": "紫系腰带·初", "slot": "belt", "type": "belt", "level": 5, "stats": {"health": 77, "defense": 9, "combatBoost": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 5}, {"id": 1771671550387.749, "name": "天珠焰心链", "slot": "necklace", "type": "necklace", "level": 6, "stats": {"health": 127, "healBoost": 0.04, "spiritRate": 0.04}, "quality": "common", "category": "equipment", "equipType": "necklace", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 6}, {"id": 1771671550387.9387, "name": "草兔", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 8, "strength": 7, "constitution": 3, "intelligence": 9}, "experience": 0, "description": "温顺的兔类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 13, "health": 114, "defense": 7, "critRate": 0.07, "stunRate": 0.08, "comboRate": 0.07, "dodgeRate": 0.08, "healBoost": 0.08, "critResist": 0.06, "stunResist": 0.07, "combatBoost": 0.08, "comboResist": 0.06, "counterRate": 0.09, "dodgeResist": 0.09, "vampireRate": 0.1, "counterResist": 0.09, "vampireResist": 0.1, "critDamageBoost": 0.09, "resistanceBoost": 0.09, "critDamageReduce": 0.08, "finalDamageBoost": 0.05, "finalDamageReduce": 0.09}}, {"id": 1771671550387.961, "name": "火凤凰", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 6, "strength": 7, "constitution": 4, "intelligence": 1}, "experience": 0, "description": "浴火重生的永恒之鸟", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 23, "attack": 36, "health": 358, "defense": 18, "critRate": 0.12, "stunRate": 0.13, "comboRate": 0.12, "dodgeRate": 0.09, "healBoost": 0.14, "critResist": 0.14, "stunResist": 0.12, "combatBoost": 0.14, "comboResist": 0.1, "counterRate": 0.13, "dodgeResist": 0.12, "vampireRate": 0.11, "counterResist": 0.1, "vampireResist": 0.09, "critDamageBoost": 0.1, "resistanceBoost": 0.13, "critDamageReduce": 0.11, "finalDamageBoost": 0.1, "finalDamageReduce": 0.14}}, {"id": 1771671550387.9258, "name": "天绝护腕·真", "slot": "wrist", "type": "wrist", "level": 7, "stats": {"defense": 14, "counterRate": 0.03, "vampireRate": 0.03}, "quality": "rare", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 7}, {"id": 1771671550387.3115, "name": "青莲鞋子·圣", "slot": "feet", "type": "feet", "level": 5, "stats": {"speed": 32, "defense": 30, "dodgeRate": 0.05}, "quality": "legendary", "category": "equipment", "equipType": "feet", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 2.5, "maxStatMod": 3.5}, "requiredRealm": 5}, {"id": 1771671550387.321, "name": "地甲", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 1, "strength": 6, "constitution": 4, "intelligence": 6}, "experience": 0, "description": "坚固的大地守护者", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 15, "attack": 29, "health": 211, "defense": 14, "critRate": 0.13, "stunRate": 0.11, "comboRate": 0.11, "dodgeRate": 0.08, "healBoost": 0.1, "critResist": 0.11, "stunResist": 0.12, "combatBoost": 0.13, "comboResist": 0.1, "counterRate": 0.14, "dodgeResist": 0.08, "vampireRate": 0.09, "counterResist": 0.12, "vampireResist": 0.09, "critDamageBoost": 0.11, "resistanceBoost": 0.11, "critDamageReduce": 0.09, "finalDamageBoost": 0.08, "finalDamageReduce": 0.12}}, {"id": 1771671550387.189, "name": "赤命符文戒1·初", "slot": "ring1", "type": "ring1", "level": 12, "stats": {"attack": 22, "critDamageBoost": 0.04, "finalDamageBoost": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "ring1", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 12}, {"id": 1771671550387.9033, "name": "赤炎焰杖", "slot": "weapon", "type": "weapon", "level": 4, "stats": {"attack": 15, "critRate": 0.02, "critDamageBoost": 0.04}, "quality": "common", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 4}, {"id": 1771671550387.3376, "name": "青系腰带·初", "slot": "belt", "type": "belt", "level": 7, "stats": {"health": 130, "defense": 10, "combatBoost": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 7}, {"id": 1771671550387.9429, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 8, "constitution": 5, "intelligence": 7}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 12, "health": 114, "defense": 7, "critRate": 0.1, "stunRate": 0.08, "comboRate": 0.07, "dodgeRate": 0.08, "healBoost": 0.08, "critResist": 0.05, "stunResist": 0.05, "combatBoost": 0.08, "comboResist": 0.06, "counterRate": 0.08, "dodgeResist": 0.07, "vampireRate": 0.05, "counterResist": 0.08, "vampireResist": 0.09, "critDamageBoost": 0.09, "resistanceBoost": 0.07, "critDamageReduce": 0.05, "finalDamageBoost": 0.07, "finalDamageReduce": 0.07}}, {"id": 1771671550387.2876, "name": "玄命符文戒1·初", "slot": "ring1", "type": "ring1", "level": 8, "stats": {"attack": 18, "critDamageBoost": 0.04, "finalDamageBoost": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "ring1", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 8}, {"id": 1771671550387.1743, "name": "天珠焰心链", "slot": "necklace", "type": "necklace", "level": 7, "stats": {"health": 142, "healBoost": 0.04, "spiritRate": 0.04}, "quality": "common", "category": "equipment", "equipType": "necklace", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 7}, {"id": 1771671550387.9436, "name": "火鼠", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 6, "constitution": 8, "intelligence": 8}, "experience": 0, "description": "活泼的啮齿类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 14, "health": 108, "defense": 5, "critRate": 0.09, "stunRate": 0.09, "comboRate": 0.08, "dodgeRate": 0.09, "healBoost": 0.06, "critResist": 0.06, "stunResist": 0.09, "combatBoost": 0.09, "comboResist": 0.08, "counterRate": 0.09, "dodgeResist": 0.06, "vampireRate": 0.09, "counterResist": 0.1, "vampireResist": 0.07, "critDamageBoost": 0.08, "resistanceBoost": 0.07, "critDamageReduce": 0.06, "finalDamageBoost": 0.07, "finalDamageReduce": 0.06}}, {"id": 1771671550387.584, "name": "赤铜护腕·初", "slot": "wrist", "type": "wrist", "level": 8, "stats": {"defense": 10, "counterRate": 0.02, "vampireRate": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 8}, {"id": 1771671550387.1716, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 4, "strength": 10, "constitution": 9, "intelligence": 1}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 9, "attack": 12, "health": 118, "defense": 7, "critRate": 0.08, "stunRate": 0.08, "comboRate": 0.07, "dodgeRate": 0.05, "healBoost": 0.08, "critResist": 0.07, "stunResist": 0.09, "combatBoost": 0.1, "comboResist": 0.06, "counterRate": 0.07, "dodgeResist": 0.1, "vampireRate": 0.1, "counterResist": 0.09, "vampireResist": 0.09, "critDamageBoost": 0.06, "resistanceBoost": 0.1, "critDamageReduce": 0.07, "finalDamageBoost": 0.09, "finalDamageReduce": 0.07}}, {"id": 1771671550387.1511, "name": "青龙衣服", "slot": "body", "type": "body", "level": 4, "stats": {"health": 152, "defense": 18, "finalDamageReduce": 0.08}, "quality": "common", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 4}, {"id": 1771671550387.5928, "name": "赤道符文戒2", "slot": "ring2", "type": "ring2", "level": 11, "stats": {"defense": 11, "resistanceBoost": 0.02, "critDamageReduce": 0.04}, "quality": "common", "category": "equipment", "equipType": "ring2", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 11}, {"id": 1771671550387.1677, "name": "风隼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 7, "strength": 5, "constitution": 9, "intelligence": 7}, "experience": 0, "description": "速度极快的飞行焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 17, "attack": 22, "health": 220, "defense": 14, "critRate": 0.1, "stunRate": 0.12, "comboRate": 0.07, "dodgeRate": 0.1, "healBoost": 0.1, "critResist": 0.07, "stunResist": 0.1, "combatBoost": 0.1, "comboResist": 0.08, "counterRate": 0.08, "dodgeResist": 0.14, "vampireRate": 0.11, "counterResist": 0.14, "vampireResist": 0.07, "critDamageBoost": 0.11, "resistanceBoost": 0.13, "critDamageReduce": 0.1, "finalDamageBoost": 0.12, "finalDamageReduce": 0.14}}, {"id": 1771671550387.946, "name": "玄龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 5, "strength": 7, "constitution": 6, "intelligence": 5}, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 13, "attack": 28, "health": 214, "defense": 10, "critRate": 0.12, "stunRate": 0.1, "comboRate": 0.11, "dodgeRate": 0.13, "healBoost": 0.13, "critResist": 0.13, "stunResist": 0.14, "combatBoost": 0.07, "comboResist": 0.13, "counterRate": 0.1, "dodgeResist": 0.13, "vampireRate": 0.11, "counterResist": 0.09, "vampireResist": 0.09, "critDamageBoost": 0.14, "resistanceBoost": 0.14, "critDamageReduce": 0.12, "finalDamageBoost": 0.13, "finalDamageReduce": 0.08}}, {"id": 1771671550387.812, "name": "赤炎焰杖·真", "slot": "weapon", "type": "weapon", "level": 12, "stats": {"attack": 46, "critRate": 0.03, "critDamageBoost": 0.06}, "quality": "rare", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 12}, {"id": 1771671550387.6099, "name": "星光裤子", "slot": "legs", "type": "legs", "level": 13, "stats": {"speed": 16, "defense": 16, "dodgeRate": 0.02}, "quality": "common", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 13}, {"id": 1771671550387.5217, "name": "玄铁护腕", "slot": "wrist", "type": "wrist", "level": 4, "stats": {"defense": 9, "counterRate": 0.02, "vampireRate": 0.02}, "quality": "common", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 4}, {"id": 1771671550387.9197, "name": "紫电裤子", "slot": "legs", "type": "legs", "level": 9, "stats": {"speed": 17, "defense": 20, "dodgeRate": 0.02}, "quality": "common", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 9}, {"id": 1771671550387.6511, "name": "星道符文戒2·初", "slot": "ring2", "type": "ring2", "level": 7, "stats": {"defense": 11, "resistanceBoost": 0.02, "critDamageReduce": 0.04}, "quality": "uncommon", "category": "equipment", "equipType": "ring2", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 7}, {"id": 1771671550387.1348, "name": "星宝焰器", "slot": "artifact", "type": "artifact", "level": 8, "stats": {"attack": 0, "critRate": 0.04, "comboRate": 0.02}, "quality": "common", "category": "equipment", "equipType": "artifact", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 8}, {"id": 1771671550387.075, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 9, "strength": 10, "constitution": 4, "intelligence": 9}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 15, "health": 110, "defense": 7, "critRate": 0.05, "stunRate": 0.08, "comboRate": 0.08, "dodgeRate": 0.1, "healBoost": 0.08, "critResist": 0.06, "stunResist": 0.08, "combatBoost": 0.07, "comboResist": 0.07, "counterRate": 0.09, "dodgeResist": 0.08, "vampireRate": 0.1, "counterResist": 0.06, "vampireResist": 0.06, "critDamageBoost": 0.09, "resistanceBoost": 0.06, "critDamageReduce": 0.07, "finalDamageBoost": 0.08, "finalDamageReduce": 0.08}}, {"id": 1771671550387.6975, "name": "风隼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 5, "strength": 10, "constitution": 9, "intelligence": 8}, "experience": 0, "description": "速度极快的飞行焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 12, "attack": 22, "health": 214, "defense": 15, "critRate": 0.09, "stunRate": 0.1, "comboRate": 0.08, "dodgeRate": 0.13, "healBoost": 0.11, "critResist": 0.07, "stunResist": 0.08, "combatBoost": 0.13, "comboResist": 0.14, "counterRate": 0.1, "dodgeResist": 0.08, "vampireRate": 0.12, "counterResist": 0.12, "vampireResist": 0.09, "critDamageBoost": 0.13, "resistanceBoost": 0.07, "critDamageReduce": 0.09, "finalDamageBoost": 0.14, "finalDamageReduce": 0.1}}, {"id": 1771671550387.5603, "name": "冰狼", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 6, "strength": 6, "constitution": 1, "intelligence": 1}, "experience": 0, "description": "冰原霸主", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 20, "attack": 32, "health": 348, "defense": 21, "critRate": 0.09, "stunRate": 0.12, "comboRate": 0.15, "dodgeRate": 0.16, "healBoost": 0.1, "critResist": 0.12, "stunResist": 0.13, "combatBoost": 0.15, "comboResist": 0.11, "counterRate": 0.12, "dodgeResist": 0.13, "vampireRate": 0.1, "counterResist": 0.12, "vampireResist": 0.11, "critDamageBoost": 0.09, "resistanceBoost": 0.08, "critDamageReduce": 0.14, "finalDamageBoost": 0.14, "finalDamageReduce": 0.09}}, {"id": 1771671550387.123, "name": "灵猫", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 7, "strength": 2, "constitution": 9, "intelligence": 5}, "experience": 0, "description": "敏捷的小型焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 6, "attack": 13, "health": 101, "defense": 5, "critRate": 0.06, "stunRate": 0.07, "comboRate": 0.05, "dodgeRate": 0.06, "healBoost": 0.08, "critResist": 0.08, "stunResist": 0.07, "combatBoost": 0.07, "comboResist": 0.05, "counterRate": 0.09, "dodgeResist": 0.1, "vampireRate": 0.06, "counterResist": 0.05, "vampireResist": 0.06, "critDamageBoost": 0.06, "resistanceBoost": 0.1, "critDamageReduce": 0.09, "finalDamageBoost": 0.06, "finalDamageReduce": 0.06}}, {"id": 1771671550387.0647, "name": "天罡裤子·极", "slot": "legs", "type": "legs", "level": 8, "stats": {"speed": 32, "defense": 35, "dodgeRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 8}, {"id": 1771671550387.7336, "name": "灵猫", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 8, "strength": 2, "constitution": 3, "intelligence": 9}, "experience": 0, "description": "敏捷的小型焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 11, "health": 103, "defense": 6, "critRate": 0.06, "stunRate": 0.1, "comboRate": 0.1, "dodgeRate": 0.05, "healBoost": 0.08, "critResist": 0.06, "stunResist": 0.09, "combatBoost": 0.08, "comboResist": 0.08, "counterRate": 0.09, "dodgeResist": 0.09, "vampireRate": 0.06, "counterResist": 0.08, "vampireResist": 0.07, "critDamageBoost": 0.06, "resistanceBoost": 0.09, "critDamageReduce": 0.08, "finalDamageBoost": 0.06, "finalDamageReduce": 0.06}}, {"id": 1771671464433.3562, "name": "云甲肩甲·初", "slot": "shoulder", "type": "shoulder", "level": 3, "stats": {"health": 121, "defense": 13, "counterRate": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 3}, {"id": 1771671531719.224, "name": "天行鞋子·极", "slot": "feet", "type": "feet", "level": 12, "stats": {"speed": 51, "defense": 19, "dodgeRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "feet", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 12}, {"id": 1771671542604.0227, "name": "玄系腰带", "slot": "belt", "type": "belt", "level": 10, "stats": {"health": 89, "defense": 12, "combatBoost": 0.02}, "quality": "common", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 10}, {"id": 1771671550166.5647, "name": "赤铜护腕", "slot": "wrist", "type": "wrist", "level": 3, "stats": {"defense": 5, "counterRate": 0.02, "vampireRate": 0.02}, "quality": "common", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 3}, {"id": 1771671550219.6743, "name": "混元衣服", "slot": "body", "type": "body", "level": 4, "stats": {"health": 145, "defense": 20, "finalDamageReduce": 0.08}, "quality": "common", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 4}, {"id": 1771671550219.7996, "name": "天护肩甲·初", "slot": "shoulder", "type": "shoulder", "level": 6, "stats": {"health": 135, "defense": 12, "counterRate": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 6}, {"id": 1771671550219.5544, "name": "幽岚肩甲·初", "slot": "shoulder", "type": "shoulder", "level": 7, "stats": {"health": 88, "defense": 14, "counterRate": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 7}, {"id": 1771671550387.261, "name": "混沌焰杖·初", "slot": "weapon", "type": "weapon", "level": 12, "stats": {"attack": 44, "critRate": 0.02, "critDamageBoost": 0.05}, "quality": "uncommon", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 12}, {"id": 1771671550387.607, "name": "九天焰杖·极", "slot": "weapon", "type": "weapon", "level": 5, "stats": {"attack": 33, "critRate": 0.04, "critDamageBoost": 0.08}, "quality": "epic", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 5}, {"id": 1771671550219.0278, "name": "紫晶手套·初", "slot": "hands", "type": "hands", "level": 13, "stats": {"attack": 22, "critRate": 0.02, "comboRate": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "hands", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 13}, {"id": 1771671550219.7185, "name": "幽系腰带·初", "slot": "belt", "type": "belt", "level": 9, "stats": {"health": 176, "defense": 18, "combatBoost": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 9}, {"id": 1771671550387.6062, "name": "云道符文戒2·真", "slot": "ring2", "type": "ring2", "level": 6, "stats": {"defense": 14, "resistanceBoost": 0.03, "critDamageReduce": 0.06}, "quality": "rare", "category": "equipment", "equipType": "ring2", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 6}, {"id": 1771671550387.8403, "name": "幽宝焰器", "slot": "artifact", "type": "artifact", "level": 11, "stats": {"attack": 0, "critRate": 0.04, "comboRate": 0.02}, "quality": "common", "category": "equipment", "equipType": "artifact", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 11}, {"id": 1771671550387.9902, "name": "云雾裤子·初", "slot": "legs", "type": "legs", "level": 10, "stats": {"speed": 17, "defense": 20, "dodgeRate": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 10}, {"id": 1771671550387.83, "name": "紫金头部", "slot": "head", "type": "head", "level": 5, "stats": {"health": 119, "defense": 14, "stunResist": 0.08}, "quality": "common", "category": "equipment", "equipType": "head", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 5}, {"id": 1771671550387.6843, "name": "幽魄焰心链", "slot": "necklace", "type": "necklace", "level": 13, "stats": {"health": 210, "healBoost": 0.04, "spiritRate": 0.04}, "quality": "common", "category": "equipment", "equipType": "necklace", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 13}, {"id": 1771671550387.98, "name": "赤金手套·极", "slot": "hands", "type": "hands", "level": 10, "stats": {"attack": 27, "critRate": 0.03, "comboRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "hands", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 10}, {"id": 1771671550387.1304, "name": "玄阳衣服·初", "slot": "body", "type": "body", "level": 10, "stats": {"health": 228, "defense": 23, "finalDamageReduce": 0.09}, "quality": "uncommon", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 10}, {"id": 1771671550387.822, "name": "玄风鞋子·初", "slot": "feet", "type": "feet", "level": 13, "stats": {"speed": 32, "defense": 19, "dodgeRate": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "feet", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 13}, {"id": 1771671550387.7256, "name": "九天焰杖·初", "slot": "weapon", "type": "weapon", "level": 3, "stats": {"attack": 16, "critRate": 0.02, "critDamageBoost": 0.05}, "quality": "uncommon", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 3}, {"id": 1771671550387.203, "name": "云霄头部·真", "slot": "head", "type": "head", "level": 6, "stats": {"health": 172, "defense": 23, "stunResist": 0.12}, "quality": "rare", "category": "equipment", "equipType": "head", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 6}, {"id": 1771671550387.1348, "name": "天珠焰心链", "slot": "necklace", "type": "necklace", "level": 9, "stats": {"health": 177, "healBoost": 0.04, "spiritRate": 0.04}, "quality": "common", "category": "equipment", "equipType": "necklace", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 9}, {"id": 1771671550387.9136, "name": "幽钢护腕·初", "slot": "wrist", "type": "wrist", "level": 10, "stats": {"defense": 17, "counterRate": 0.02, "vampireRate": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 10}, {"id": 1771671550387.4053, "name": "青锋肩甲", "slot": "shoulder", "type": "shoulder", "level": 6, "stats": {"health": 65, "defense": 16, "counterRate": 0.02}, "quality": "common", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 6}, {"id": 1771671550387.871, "name": "云踪鞋子", "slot": "feet", "type": "feet", "level": 12, "stats": {"speed": 30, "defense": 11, "dodgeRate": 0.02}, "quality": "common", "category": "equipment", "equipType": "feet", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 12}, {"id": 1771671550387.2122, "name": "混元衣服·真", "slot": "body", "type": "body", "level": 4, "stats": {"health": 249, "defense": 17, "finalDamageReduce": 0.12}, "quality": "rare", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 4}, {"id": 1771671550387.4995, "name": "云珠焰心链·初", "slot": "necklace", "type": "necklace", "level": 13, "stats": {"health": 211, "healBoost": 0.04, "spiritRate": 0.04}, "quality": "uncommon", "category": "equipment", "equipType": "necklace", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 13}, {"id": 1771671550387.0796, "name": "云雾裤子·极", "slot": "legs", "type": "legs", "level": 10, "stats": {"speed": 24, "defense": 24, "dodgeRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 10}, {"id": 1771671550387.7537, "name": "赤命符文戒1", "slot": "ring1", "type": "ring1", "level": 4, "stats": {"attack": 9, "critDamageBoost": 0.04, "finalDamageBoost": 0.02}, "quality": "common", "category": "equipment", "equipType": "ring1", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 4}, {"id": 1771671550387.43, "name": "青命符文戒1", "slot": "ring1", "type": "ring1", "level": 11, "stats": {"attack": 18, "critDamageBoost": 0.04, "finalDamageBoost": 0.02}, "quality": "common", "category": "equipment", "equipType": "ring1", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 11}, {"id": 1771671550387.4424, "name": "玄宝焰器·初", "slot": "artifact", "type": "artifact", "level": 3, "stats": {"attack": 0, "critRate": 0.04, "comboRate": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "artifact", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.2, "maxStatMod": 2}, "requiredRealm": 3}, {"id": 1771671550387.47, "name": "太素衣服·极", "slot": "body", "type": "body", "level": 3, "stats": {"health": 306, "defense": 29, "finalDamageReduce": 0.12}, "quality": "epic", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 3}, {"id": 1771671550387.3005, "name": "混元衣服·极", "slot": "body", "type": "body", "level": 7, "stats": {"health": 412, "defense": 36, "finalDamageReduce": 0.12}, "quality": "epic", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 7}, {"id": 1771671550387.4897, "name": "赤金手套·极", "slot": "hands", "type": "hands", "level": 7, "stats": {"attack": 32, "critRate": 0.03, "comboRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "hands", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 7}, {"id": 1771671550387.554, "name": "幽银手套", "slot": "hands", "type": "hands", "level": 7, "stats": {"attack": 12, "critRate": 0.01, "comboRate": 0.02}, "quality": "common", "category": "equipment", "equipType": "hands", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 7}, {"id": 1771671550387.886, "name": "九天焰杖·真", "slot": "weapon", "type": "weapon", "level": 12, "stats": {"attack": 39, "critRate": 0.03, "critDamageBoost": 0.06}, "quality": "rare", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 12}], "level": 5, "realm": "燃火五重", "spirit": 700, "gachaPity": {"petCount": 3, "equipCount": 1}, "_nakedBase": {"speed": 37, "attack": 81, "health": 800, "defense": 49}, "petEssence": 595, "realmIndex": 12, "spiritRate": 1.2, "cultivation": 38000, "spiritStones": 438000, "baseAttributes": {"speed": 51, "attack": 81, "health": 800, "defense": 80}, "maxCultivation": 600, "artifactBonuses": {"speed": 14, "attack": 0, "health": 0, "defense": 31, "critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0.24, "healBoost": 0, "critResist": 0, "spiritRate": 0, "stunResist": 0, "combatBoost": 0, "comboResist": 0, "counterRate": 0, "dodgeResist": 0, "vampireRate": 0, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0, "cultivationRate": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "reinforceStones": 1, "combatAttributes": {"critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0.24, "counterRate": 0, "vampireRate": 0}, "combatResistance": {"critResist": 0, "stunResist": 0, "comboResist": 0, "dodgeResist": 0, "counterResist": 0, "vampireResist": 0}, "equippedArtifacts": {"belt": null, "body": null, "feet": null, "head": null, "legs": {"id": 1771671550387.9841, "name": "星光裤子·天", "slot": "legs", "type": "legs", "level": 8, "stats": {"speed": 14, "defense": 31, "dodgeRate": 0.03}, "quality": "rare", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 8}, "hands": null, "ring1": null, "ring2": null, "wrist": null, "weapon": null, "artifact": null, "necklace": null, "shoulder": null}, "specialAttributes": {"healBoost": 0, "combatBoost": 0, "critDamageBoost": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}}	0	0.00000000	438000	5	燃火五重	0	f	\N	0	2026-02-20 23:40:27.028843	2026-02-22 02:35:30.534873	f	403
20	0x1dbbef8203a357b35a0da09f5ab4e1a5e19528ec	无名修士	{"level": 1, "spirit": 245, "_nakedBase": {"speed": 10, "attack": 10, "health": 100, "defense": 5}, "lastTickTime": 1771932123243, "baseAttributes": {"speed": 10, "attack": 10, "health": 100, "defense": 5}, "artifactBonuses": {"speed": 0, "attack": 0, "health": 0, "defense": 0, "critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "healBoost": 0, "critResist": 0, "spiritRate": 0, "stunResist": 0, "combatBoost": 0, "comboResist": 0, "counterRate": 0, "dodgeResist": 0, "vampireRate": 0, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0, "cultivationRate": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "combatAttributes": {"critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "counterRate": 0, "vampireRate": 0}, "combatResistance": {"critResist": 0, "stunResist": 0, "comboResist": 0, "dodgeResist": 0, "counterResist": 0, "vampireResist": 0}, "equippedArtifacts": {}, "specialAttributes": {"healBoost": 0, "combatBoost": 0, "critDamageBoost": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}}	0	0.00000000	0	1	燃火期一层	0	f	\N	0	2026-02-24 06:20:22.668917	2026-02-24 06:22:03.244883	f	0
21	0xbot001	焰影·烈风	{"items": [], "level": 68, "realm": "大焰七重", "spirit": 1000, "cultivation": 50000, "spiritStones": 10000, "maxCultivation": 100000, "combatAttributes": {"speed": 4500, "attack": 13500, "health": 90000, "defense": 6750, "critRate": 0.15, "dodgeRate": 0.05, "critDamage": 0.5, "vampireRate": 0.03}}	0	0.00000000	10000	68	大焰七重	45000	f	\N	0	2026-02-24 13:15:37.181213	2026-02-24 13:15:37.181213	f	0
19	0x61d6ef2759c9f6c8d6dd1a5d6bc422904d0dfad5	无名焰修	{"luck": 1, "name": "无名焰修", "buffs": {}, "herbs": [], "items": [], "level": 2, "pills": [], "realm": "燃火二重", "spirit": 400, "herbRate": 1, "isGMMode": false, "vipLevel": 0, "activePet": null, "artifacts": [], "petConfig": {"rarityMap": {"divine": {"name": "神品", "color": "#FF0000", "probability": 0.02, "essenceBonus": 50}, "mortal": {"name": "凡品", "color": "#32CD32", "probability": 0.5, "essenceBonus": 5}, "mystic": {"name": "玄品", "color": "#9932CC", "probability": 0.15, "essenceBonus": 20}, "celestial": {"name": "仙品", "color": "#FFD700", "probability": 0.08, "essenceBonus": 30}, "spiritual": {"name": "灵品", "color": "#1E90FF", "probability": 0.25, "essenceBonus": 10}}}, "_nakedBase": {"speed": 12, "attack": 15, "health": 150, "defense": 8}, "isDarkMode": false, "itemsFound": 0, "petEssence": 0, "spiritRate": 1, "alchemyRate": 1, "cultivation": 108, "isNewPlayer": true, "pillRecipes": [], "lastTickTime": 1771872261520, "pillsCrafted": 0, "spiritStones": 5342, "activeEffects": [], "pillFragments": {}, "pillsConsumed": 0, "storageExpand": {}, "baseAttributes": {"speed": 12, "attack": 15, "health": 150, "defense": 8}, "eventTriggered": 0, "lastOnlineTime": 1771872261520, "maxCultivation": 200, "unlockedRealms": ["燃火一层"], "unlockedSkills": [], "artifactBonuses": {"speed": 0, "attack": 0, "health": 0, "defense": 0, "critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "healBoost": 0, "critResist": 0, "spiritRate": 0, "stunResist": 0, "combatBoost": 0, "comboResist": 0, "counterRate": 0, "dodgeResist": 0, "vampireRate": 0, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0, "cultivationRate": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "cultivationRate": 1, "nameChangeCount": 0, "reinforceStones": 0, "wishlistEnabled": false, "activeMountBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "activeTitleBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "combatAttributes": {"critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "counterRate": 0, "vampireRate": 0}, "combatResistance": {"critResist": 0, "stunResist": 0, "comboResist": 0, "dodgeResist": 0, "counterResist": 0, "vampireResist": 0}, "dungeonBossKills": 0, "dungeonTotalRuns": 0, "explorationCount": 0, "refinementStones": 0, "autoSellQualities": [], "breakthroughCount": 1, "dungeonDeathCount": 0, "dungeonDifficulty": 1, "dungeonEliteKills": 0, "dungeonTotalKills": 0, "equippedArtifacts": {}, "isAutoCultivating": false, "specialAttributes": {"healBoost": 0, "combatBoost": 0, "critDamageBoost": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "unlockedLocations": ["新手村"], "autoReleaseRarities": [], "dungeonHighestFloor": 0, "dungeonTotalRewards": 0, "unlockedPillRecipes": 0, "totalCultivationTime": 0, "completedAchievements": [], "dungeonHighestFloor_2": 0, "dungeonHighestFloor_5": 0, "selectedWishPetRarity": null, "dungeonHighestFloor_10": 0, "dungeonLastFailedFloor": 0, "dungeonHighestFloor_100": 0, "selectedWishEquipQuality": null}	0	0.00000000	5342	2	燃火二重	225	f	\N	0	2026-02-23 13:12:00.369008	2026-02-23 13:44:21.52072	f	28
2	0x82e402b05f3e936b63a874788c73e1552657c4f7	测试账号 1	{"luck": 1, "name": "测试账号 1", "buffs": {}, "herbs": [{"id": "drop_5", "name": "灵精草", "value": 20, "herbId": "spirit_grass", "quality": "rare", "obtainedAt": 1771686644248}, {"id": "drop_8", "name": "灵精草", "value": 20, "herbId": "spirit_grass", "quality": "rare", "obtainedAt": 1771686644251}, {"id": "drop_9", "name": "灵精草", "value": 30, "herbId": "spirit_grass", "quality": "epic", "obtainedAt": 1771686644252}, {"id": "drop_11", "name": "灵精草", "value": 30, "herbId": "spirit_grass", "quality": "epic", "obtainedAt": 1771686644254}, {"id": "drop_12", "name": "灵精草", "value": 30, "herbId": "spirit_grass", "quality": "epic", "obtainedAt": 1771686644255}, {"id": "drop_15", "name": "灵精草", "value": 30, "herbId": "spirit_grass", "quality": "epic", "obtainedAt": 1771686644258}, {"id": "drop_29", "name": "云雾花", "value": 30, "herbId": "cloud_flower", "quality": "rare", "obtainedAt": 1771686644272}, {"id": "drop_30", "name": "云雾花", "value": 30, "herbId": "cloud_flower", "quality": "rare", "obtainedAt": 1771686644273}, {"id": "drop_32", "name": "云雾花", "value": 45, "herbId": "cloud_flower", "quality": "epic", "obtainedAt": 1771686644275}, {"id": "drop_37", "name": "云雾花", "value": 45, "herbId": "cloud_flower", "quality": "epic", "obtainedAt": 1771686644280}, {"id": "drop_47", "name": "雷击根", "value": 75, "herbId": "thunder_root", "quality": "epic", "obtainedAt": 1771686644290}, {"id": "drop_48", "name": "雷击根", "value": 75, "herbId": "thunder_root", "quality": "epic", "obtainedAt": 1771686644291}, {"id": "drop_50", "name": "雷击根", "value": 75, "herbId": "thunder_root", "quality": "epic", "obtainedAt": 1771686644293}, {"id": "drop_53", "name": "雷击根", "value": 75, "herbId": "thunder_root", "quality": "epic", "obtainedAt": 1771686644296}, {"id": "drop_67", "name": "仙玉草", "value": 180, "herbId": "immortal_jade_grass", "quality": "epic", "obtainedAt": 1771686644310}, {"id": "drop_68", "name": "仙玉草", "value": 120, "herbId": "immortal_jade_grass", "quality": "rare", "obtainedAt": 1771686644311}, {"id": "drop_71", "name": "仙玉草", "value": 180, "herbId": "immortal_jade_grass", "quality": "epic", "obtainedAt": 1771686644314}, {"id": "drop_72", "name": "仙玉草", "value": 180, "herbId": "immortal_jade_grass", "quality": "epic", "obtainedAt": 1771686644315}, {"id": "drop_81", "name": "九叶灵芝", "value": 240, "herbId": "nine_leaf_lingzhi", "quality": "epic", "obtainedAt": 1771686644324}, {"id": "drop_82", "name": "九叶灵芝", "value": 240, "herbId": "nine_leaf_lingzhi", "quality": "epic", "obtainedAt": 1771686644325}, {"id": "drop_84", "name": "紫参", "value": 210, "herbId": "purple_ginseng", "quality": "epic", "obtainedAt": 1771686644327}, {"id": "drop_85", "name": "紫参", "value": 210, "herbId": "purple_ginseng", "quality": "epic", "obtainedAt": 1771686644328}, {"id": "drop_86", "name": "紫参", "value": 140, "herbId": "purple_ginseng", "quality": "rare", "obtainedAt": 1771686644329}, {"id": "air_95", "name": "灵精草", "value": 30, "herbId": "spirit_grass", "quality": "epic", "obtainedAt": 1771687886383}, {"id": "air_97", "name": "灵精草", "value": 20, "herbId": "spirit_grass", "quality": "rare", "obtainedAt": 1771687886385}, {"id": "air_98", "name": "灵精草", "value": 30, "herbId": "spirit_grass", "quality": "epic", "obtainedAt": 1771687886386}, {"id": "air_99", "name": "灵精草", "value": 20, "herbId": "spirit_grass", "quality": "rare", "obtainedAt": 1771687886387}, {"id": "air_100", "name": "灵精草", "value": 20, "herbId": "spirit_grass", "quality": "rare", "obtainedAt": 1771687886388}, {"id": "air_101", "name": "灵精草", "value": 30, "herbId": "spirit_grass", "quality": "epic", "obtainedAt": 1771687886389}, {"id": "air_104", "name": "灵精草", "value": 30, "herbId": "spirit_grass", "quality": "epic", "obtainedAt": 1771687886392}, {"id": "air_107", "name": "灵精草", "value": 20, "herbId": "spirit_grass", "quality": "rare", "obtainedAt": 1771687886395}, {"id": "air_112", "name": "灵精草", "value": 30, "herbId": "spirit_grass", "quality": "epic", "obtainedAt": 1771687886400}, {"id": "air_114", "name": "灵精草", "value": 30, "herbId": "spirit_grass", "quality": "epic", "obtainedAt": 1771687886402}, {"id": "air_122", "name": "灵精草", "value": 30, "herbId": "spirit_grass", "quality": "epic", "obtainedAt": 1771687886410}, {"id": "air_123", "name": "灵精草", "value": 20, "herbId": "spirit_grass", "quality": "rare", "obtainedAt": 1771687886411}, {"id": "air_126", "name": "云雾花", "value": 30, "herbId": "cloud_flower", "quality": "rare", "obtainedAt": 1771687886414}, {"id": "air_130", "name": "云雾花", "value": 30, "herbId": "cloud_flower", "quality": "rare", "obtainedAt": 1771687886418}, {"id": "air_131", "name": "云雾花", "value": 30, "herbId": "cloud_flower", "quality": "rare", "obtainedAt": 1771687886419}, {"id": "air_132", "name": "云雾花", "value": 30, "herbId": "cloud_flower", "quality": "rare", "obtainedAt": 1771687886420}, {"id": "air_134", "name": "云雾花", "value": 45, "herbId": "cloud_flower", "quality": "epic", "obtainedAt": 1771687886422}, {"id": "air_135", "name": "云雾花", "value": 45, "herbId": "cloud_flower", "quality": "epic", "obtainedAt": 1771687886423}, {"id": "air_137", "name": "云雾花", "value": 30, "herbId": "cloud_flower", "quality": "rare", "obtainedAt": 1771687886425}, {"id": "air_138", "name": "云雾花", "value": 45, "herbId": "cloud_flower", "quality": "epic", "obtainedAt": 1771687886426}, {"id": "air_140", "name": "云雾花", "value": 30, "herbId": "cloud_flower", "quality": "rare", "obtainedAt": 1771687886428}, {"id": "air_142", "name": "云雾花", "value": 30, "herbId": "cloud_flower", "quality": "rare", "obtainedAt": 1771687886430}, {"id": "air_143", "name": "云雾花", "value": 30, "herbId": "cloud_flower", "quality": "rare", "obtainedAt": 1771687886431}, {"id": "air_144", "name": "云雾花", "value": 45, "herbId": "cloud_flower", "quality": "epic", "obtainedAt": 1771687886432}, {"id": "air_149", "name": "云雾花", "value": 30, "herbId": "cloud_flower", "quality": "rare", "obtainedAt": 1771687886437}, {"id": "air_150", "name": "云雾花", "value": 30, "herbId": "cloud_flower", "quality": "rare", "obtainedAt": 1771687886438}, {"id": "air_151", "name": "云雾花", "value": 30, "herbId": "cloud_flower", "quality": "rare", "obtainedAt": 1771687886439}, {"id": "air_152", "name": "云雾花", "value": 45, "herbId": "cloud_flower", "quality": "epic", "obtainedAt": 1771687886440}, {"id": "air_153", "name": "云雾花", "value": 30, "herbId": "cloud_flower", "quality": "rare", "obtainedAt": 1771687886441}, {"id": "air_155", "name": "雷击根", "value": 75, "herbId": "thunder_root", "quality": "epic", "obtainedAt": 1771687886443}, {"id": "air_157", "name": "雷击根", "value": 75, "herbId": "thunder_root", "quality": "epic", "obtainedAt": 1771687886445}, {"id": "air_158", "name": "雷击根", "value": 50, "herbId": "thunder_root", "quality": "rare", "obtainedAt": 1771687886446}, {"id": "air_162", "name": "雷击根", "value": 75, "herbId": "thunder_root", "quality": "epic", "obtainedAt": 1771687886450}, {"id": "air_163", "name": "雷击根", "value": 50, "herbId": "thunder_root", "quality": "rare", "obtainedAt": 1771687886451}, {"id": "air_164", "name": "雷击根", "value": 50, "herbId": "thunder_root", "quality": "rare", "obtainedAt": 1771687886452}, {"id": "air_165", "name": "雷击根", "value": 50, "herbId": "thunder_root", "quality": "rare", "obtainedAt": 1771687886453}, {"id": "air_167", "name": "雷击根", "value": 75, "herbId": "thunder_root", "quality": "epic", "obtainedAt": 1771687886455}, {"id": "air_168", "name": "雷击根", "value": 75, "herbId": "thunder_root", "quality": "epic", "obtainedAt": 1771687886456}, {"id": "air_171", "name": "雷击根", "value": 75, "herbId": "thunder_root", "quality": "epic", "obtainedAt": 1771687886459}, {"id": "air_174", "name": "龙息草", "value": 80, "herbId": "dragon_breath_herb", "quality": "rare", "obtainedAt": 1771687886462}, {"id": "air_175", "name": "龙息草", "value": 80, "herbId": "dragon_breath_herb", "quality": "rare", "obtainedAt": 1771687886463}, {"id": "air_176", "name": "龙息草", "value": 80, "herbId": "dragon_breath_herb", "quality": "rare", "obtainedAt": 1771687886464}, {"id": "air_179", "name": "龙息草", "value": 80, "herbId": "dragon_breath_herb", "quality": "rare", "obtainedAt": 1771687886467}, {"id": "air_182", "name": "龙息草", "value": 80, "herbId": "dragon_breath_herb", "quality": "rare", "obtainedAt": 1771687886470}, {"id": "air_184", "name": "龙息草", "value": 120, "herbId": "dragon_breath_herb", "quality": "epic", "obtainedAt": 1771687886472}, {"id": "air_186", "name": "龙息草", "value": 80, "herbId": "dragon_breath_herb", "quality": "rare", "obtainedAt": 1771687886474}, {"id": "air_188", "name": "龙息草", "value": 80, "herbId": "dragon_breath_herb", "quality": "rare", "obtainedAt": 1771687886476}, {"id": "air_191", "name": "仙玉草", "value": 120, "herbId": "immortal_jade_grass", "quality": "rare", "obtainedAt": 1771687886479}, {"id": "air_193", "name": "仙玉草", "value": 180, "herbId": "immortal_jade_grass", "quality": "epic", "obtainedAt": 1771687886481}, {"id": "air_195", "name": "仙玉草", "value": 120, "herbId": "immortal_jade_grass", "quality": "rare", "obtainedAt": 1771687886483}, {"id": "air_200", "name": "九叶灵芝", "value": 240, "herbId": "nine_leaf_lingzhi", "quality": "epic", "obtainedAt": 1771687886488}, {"id": "air_201", "name": "九叶灵芝", "value": 160, "herbId": "nine_leaf_lingzhi", "quality": "rare", "obtainedAt": 1771687886489}, {"id": "air_205", "name": "九叶灵芝", "value": 160, "herbId": "nine_leaf_lingzhi", "quality": "rare", "obtainedAt": 1771687886493}, {"id": "air_212", "name": "火心花", "value": 255, "herbId": "fire_heart_flower", "quality": "epic", "obtainedAt": 1771687886500}, {"id": "air_213", "name": "火心花", "value": 255, "herbId": "fire_heart_flower", "quality": "epic", "obtainedAt": 1771687886501}, {"id": "air_214", "name": "火心花", "value": 170, "herbId": "fire_heart_flower", "quality": "rare", "obtainedAt": 1771687886502}, {"id": "air_216", "name": "火心花", "value": 255, "herbId": "fire_heart_flower", "quality": "epic", "obtainedAt": 1771687886504}, {"id": "1771749802518kg1dpl7ef", "name": "五行草", "value": 160, "herbId": "five_elements_grass", "quality": "rare", "obtainedAt": 1771749802518}, {"id": "17717498025192xmtfyiva", "name": "天露草", "value": 180, "herbId": "celestial_dew_grass", "quality": "rare", "obtainedAt": 1771749802519}, {"id": "17717498025198o0ovsfw6", "name": "月华兰", "value": 140, "herbId": "moonlight_orchid", "quality": "rare", "obtainedAt": 1771749802519}, {"id": "177174980251949hfwqu60", "name": "月华兰", "value": 140, "herbId": "moonlight_orchid", "quality": "rare", "obtainedAt": 1771749802519}, {"id": "1771935006898jn3brkku0", "name": "五行草", "value": 240, "herbId": "five_elements_grass", "quality": "epic", "obtainedAt": 1771935006899}, {"id": "1771935006899ar00i8is2", "name": "天露草", "value": 180, "herbId": "celestial_dew_grass", "quality": "rare", "obtainedAt": 1771935006899}, {"id": "1771935006899bhol9hfww", "name": "日精花", "value": 150, "herbId": "sun_essence_flower", "quality": "rare", "obtainedAt": 1771935006899}, {"id": "1771935006899ort6vu1db", "name": "凤羽草", "value": 127, "herbId": "phoenix_feather_herb", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "1771935006899blynmqvp6", "name": "月华兰", "value": 70, "herbId": "moonlight_orchid", "quality": "common", "obtainedAt": 1771935006899}, {"id": "17719350068999hur7x6ol", "name": "五行草", "value": 120, "herbId": "five_elements_grass", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "1771935006899wa923l01t", "name": "日精花", "value": 150, "herbId": "sun_essence_flower", "quality": "rare", "obtainedAt": 1771935006899}, {"id": "1771935006899pztxz05a8", "name": "日精花", "value": 225, "herbId": "sun_essence_flower", "quality": "epic", "obtainedAt": 1771935006899}, {"id": "17719350068995x0v6h2bo", "name": "凤羽草", "value": 85, "herbId": "phoenix_feather_herb", "quality": "common", "obtainedAt": 1771935006899}, {"id": "17719350068990kblnx8mh", "name": "五行草", "value": 120, "herbId": "five_elements_grass", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "1771935006899ogzh5m3y0", "name": "天露草", "value": 135, "herbId": "celestial_dew_grass", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "17719350068990yw8jcach", "name": "日精花", "value": 225, "herbId": "sun_essence_flower", "quality": "epic", "obtainedAt": 1771935006899}, {"id": "17719350068990kld6q5o1", "name": "天露草", "value": 135, "herbId": "celestial_dew_grass", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "1771935006899y6xjyr4if", "name": "天露草", "value": 135, "herbId": "celestial_dew_grass", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "1771935006899sbrqc2psw", "name": "五行草", "value": 80, "herbId": "five_elements_grass", "quality": "common", "obtainedAt": 1771935006899}, {"id": "177193500689968ezrwa6z", "name": "天露草", "value": 135, "herbId": "celestial_dew_grass", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "17719350068990mv3v4s1e", "name": "五行草", "value": 80, "herbId": "five_elements_grass", "quality": "common", "obtainedAt": 1771935006899}, {"id": "17719350068990dmed62sd", "name": "日精花", "value": 112, "herbId": "sun_essence_flower", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "1771935006899zigphtil6", "name": "天露草", "value": 135, "herbId": "celestial_dew_grass", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "17719350068992o6uvsrt7", "name": "凤羽草", "value": 170, "herbId": "phoenix_feather_herb", "quality": "rare", "obtainedAt": 1771935006899}, {"id": "1771935006899s9kepgt1i", "name": "天露草", "value": 135, "herbId": "celestial_dew_grass", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "1771935006899l8ugkkpkz", "name": "日精花", "value": 75, "herbId": "sun_essence_flower", "quality": "common", "obtainedAt": 1771935006899}, {"id": "1771935006899sl64yabks", "name": "凤羽草", "value": 127, "herbId": "phoenix_feather_herb", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "1771935006899te5vic2cp", "name": "日精花", "value": 75, "herbId": "sun_essence_flower", "quality": "common", "obtainedAt": 1771935006899}, {"id": "1771935006899xl4aq4134", "name": "日精花", "value": 75, "herbId": "sun_essence_flower", "quality": "common", "obtainedAt": 1771935006899}, {"id": "1771935006899vwa8t97qa", "name": "凤羽草", "value": 255, "herbId": "phoenix_feather_herb", "quality": "epic", "obtainedAt": 1771935006899}, {"id": "17719350068991xkexbdcy", "name": "天露草", "value": 270, "herbId": "celestial_dew_grass", "quality": "epic", "obtainedAt": 1771935006899}, {"id": "17719350068997u74vhq9q", "name": "日精花", "value": 112, "herbId": "sun_essence_flower", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "1771935006899adpqh4uj3", "name": "五行草", "value": 160, "herbId": "five_elements_grass", "quality": "rare", "obtainedAt": 1771935006899}, {"id": "17719350068997ujuq78s0", "name": "日精花", "value": 375, "herbId": "sun_essence_flower", "quality": "legendary", "obtainedAt": 1771935006899}, {"id": "1771935006899yehy1yw11", "name": "凤羽草", "value": 170, "herbId": "phoenix_feather_herb", "quality": "rare", "obtainedAt": 1771935006899}, {"id": "17719350068998hpqw5uwh", "name": "日精花", "value": 75, "herbId": "sun_essence_flower", "quality": "common", "obtainedAt": 1771935006899}, {"id": "1771935006899f68prv41w", "name": "凤羽草", "value": 85, "herbId": "phoenix_feather_herb", "quality": "common", "obtainedAt": 1771935006899}, {"id": "1771935006899rpwhf71hp", "name": "月华兰", "value": 70, "herbId": "moonlight_orchid", "quality": "common", "obtainedAt": 1771935006899}, {"id": "177193500689915i407aqh", "name": "日精花", "value": 112, "herbId": "sun_essence_flower", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "1771935006899foo4ijpjz", "name": "日精花", "value": 150, "herbId": "sun_essence_flower", "quality": "rare", "obtainedAt": 1771935006899}, {"id": "1771935006899cre372khe", "name": "日精花", "value": 75, "herbId": "sun_essence_flower", "quality": "common", "obtainedAt": 1771935006899}, {"id": "1771935006899s1rhbk3si", "name": "月华兰", "value": 70, "herbId": "moonlight_orchid", "quality": "common", "obtainedAt": 1771935006899}, {"id": "1771935006899zbnfokte6", "name": "日精花", "value": 375, "herbId": "sun_essence_flower", "quality": "legendary", "obtainedAt": 1771935006899}, {"id": "1771935006899aj4rxluoe", "name": "凤羽草", "value": 85, "herbId": "phoenix_feather_herb", "quality": "common", "obtainedAt": 1771935006899}, {"id": "1771935006899b3wj5id1j", "name": "五行草", "value": 80, "herbId": "five_elements_grass", "quality": "common", "obtainedAt": 1771935006899}, {"id": "1771935006899564q7xk7d", "name": "五行草", "value": 400, "herbId": "five_elements_grass", "quality": "legendary", "obtainedAt": 1771935006899}, {"id": "1771935006899zd34wdxd9", "name": "日精花", "value": 75, "herbId": "sun_essence_flower", "quality": "common", "obtainedAt": 1771935006899}, {"id": "1771935006899ov43tbbf6", "name": "凤羽草", "value": 127, "herbId": "phoenix_feather_herb", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "177193500689931ca4zhcp", "name": "五行草", "value": 240, "herbId": "five_elements_grass", "quality": "epic", "obtainedAt": 1771935006899}, {"id": "1771935006899suz74hc59", "name": "凤羽草", "value": 85, "herbId": "phoenix_feather_herb", "quality": "common", "obtainedAt": 1771935006899}, {"id": "1771935006899t9rdh5n6m", "name": "日精花", "value": 75, "herbId": "sun_essence_flower", "quality": "common", "obtainedAt": 1771935006899}, {"id": "177193500689965s1om152", "name": "凤羽草", "value": 85, "herbId": "phoenix_feather_herb", "quality": "common", "obtainedAt": 1771935006899}, {"id": "17719350068993l958qbo3", "name": "凤羽草", "value": 85, "herbId": "phoenix_feather_herb", "quality": "common", "obtainedAt": 1771935006899}, {"id": "17719350068991txx1o5sw", "name": "凤羽草", "value": 255, "herbId": "phoenix_feather_herb", "quality": "epic", "obtainedAt": 1771935006899}, {"id": "1771935006899u0zwj3bqf", "name": "天露草", "value": 90, "herbId": "celestial_dew_grass", "quality": "common", "obtainedAt": 1771935006899}, {"id": "177193500689974gw9wypb", "name": "月华兰", "value": 140, "herbId": "moonlight_orchid", "quality": "rare", "obtainedAt": 1771935006899}, {"id": "1771935006899bmnnnlnmy", "name": "月华兰", "value": 70, "herbId": "moonlight_orchid", "quality": "common", "obtainedAt": 1771935006899}, {"id": "1771935006899l8dqkbriq", "name": "五行草", "value": 160, "herbId": "five_elements_grass", "quality": "rare", "obtainedAt": 1771935006899}, {"id": "177193500689929prg0xho", "name": "凤羽草", "value": 85, "herbId": "phoenix_feather_herb", "quality": "common", "obtainedAt": 1771935006899}, {"id": "1771935006899zr4ondd4s", "name": "天露草", "value": 90, "herbId": "celestial_dew_grass", "quality": "common", "obtainedAt": 1771935006899}, {"id": "17719350068993w2e0fa1q", "name": "日精花", "value": 75, "herbId": "sun_essence_flower", "quality": "common", "obtainedAt": 1771935006899}, {"id": "177193500689903ozfrahm", "name": "日精花", "value": 75, "herbId": "sun_essence_flower", "quality": "common", "obtainedAt": 1771935006899}, {"id": "17719350068999keqt9n87", "name": "月华兰", "value": 105, "herbId": "moonlight_orchid", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "1771935006899gieadp8qw", "name": "月华兰", "value": 105, "herbId": "moonlight_orchid", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "1771935006899t7h4b2sbt", "name": "天露草", "value": 180, "herbId": "celestial_dew_grass", "quality": "rare", "obtainedAt": 1771935006899}, {"id": "1771935006899hk1hg3hhm", "name": "月华兰", "value": 105, "herbId": "moonlight_orchid", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "1771935006899jqped120l", "name": "天露草", "value": 180, "herbId": "celestial_dew_grass", "quality": "rare", "obtainedAt": 1771935006899}, {"id": "17719350068991oljspp3v", "name": "天露草", "value": 180, "herbId": "celestial_dew_grass", "quality": "rare", "obtainedAt": 1771935006899}, {"id": "1771935006899e2k1gowcx", "name": "天露草", "value": 135, "herbId": "celestial_dew_grass", "quality": "uncommon", "obtainedAt": 1771935006899}, {"id": "1771935006899j20cza2q6", "name": "五行草", "value": 80, "herbId": "five_elements_grass", "quality": "common", "obtainedAt": 1771935006899}, {"id": "1771935006899x3ujtcp3i", "name": "日精花", "value": 225, "herbId": "sun_essence_flower", "quality": "epic", "obtainedAt": 1771935006899}, {"id": "1771944470409qe9abgqbo", "name": "凤羽草", "value": 85, "herbId": "phoenix_feather_herb", "quality": "common", "obtainedAt": 1771944470410}, {"id": "1771944470410iyxba19j6", "name": "月华兰", "value": 105, "herbId": "moonlight_orchid", "quality": "uncommon", "obtainedAt": 1771944470410}, {"id": "1771944470410yamwkk4ov", "name": "天露草", "value": 135, "herbId": "celestial_dew_grass", "quality": "uncommon", "obtainedAt": 1771944470410}, {"id": "1771944470410wm65ha0tw", "name": "五行草", "value": 80, "herbId": "five_elements_grass", "quality": "common", "obtainedAt": 1771944470410}, {"id": "1771944470410cgscabzlw", "name": "凤羽草", "value": 425, "herbId": "phoenix_feather_herb", "quality": "legendary", "obtainedAt": 1771944470410}, {"id": "17719444704108i1fclftx", "name": "天露草", "value": 270, "herbId": "celestial_dew_grass", "quality": "epic", "obtainedAt": 1771944470410}, {"id": "1771944470410kul2fd9re", "name": "天露草", "value": 90, "herbId": "celestial_dew_grass", "quality": "common", "obtainedAt": 1771944470410}, {"id": "17719444704108hkjdbbbn", "name": "日精花", "value": 375, "herbId": "sun_essence_flower", "quality": "legendary", "obtainedAt": 1771944470410}, {"id": "17719444704107n4fp1l75", "name": "日精花", "value": 150, "herbId": "sun_essence_flower", "quality": "rare", "obtainedAt": 1771944470410}, {"id": "1771944470410iafiyhz3j", "name": "月华兰", "value": 70, "herbId": "moonlight_orchid", "quality": "common", "obtainedAt": 1771944470410}, {"id": "1771944470410xily2yitg", "name": "日精花", "value": 112, "herbId": "sun_essence_flower", "quality": "uncommon", "obtainedAt": 1771944470410}, {"id": "1771944470410lc5gp82pt", "name": "月华兰", "value": 140, "herbId": "moonlight_orchid", "quality": "rare", "obtainedAt": 1771944470410}, {"id": "17719444704108bxo0cr6f", "name": "天露草", "value": 90, "herbId": "celestial_dew_grass", "quality": "common", "obtainedAt": 1771944470410}, {"id": "1771944470410ewj5xqryw", "name": "五行草", "value": 160, "herbId": "five_elements_grass", "quality": "rare", "obtainedAt": 1771944470410}, {"id": "1771944470410njzeb6w9n", "name": "五行草", "value": 160, "herbId": "five_elements_grass", "quality": "rare", "obtainedAt": 1771944470410}, {"id": "1771944470410bz77d6pbj", "name": "凤羽草", "value": 170, "herbId": "phoenix_feather_herb", "quality": "rare", "obtainedAt": 1771944470410}, {"id": "1771944470410f3eszg20f", "name": "凤羽草", "value": 127, "herbId": "phoenix_feather_herb", "quality": "uncommon", "obtainedAt": 1771944470410}, {"id": "1771944470410af65qj4sh", "name": "日精花", "value": 150, "herbId": "sun_essence_flower", "quality": "rare", "obtainedAt": 1771944470410}, {"id": "1771944470410kvig80973", "name": "五行草", "value": 120, "herbId": "five_elements_grass", "quality": "uncommon", "obtainedAt": 1771944470410}, {"id": "1771944470410oaasphbjg", "name": "日精花", "value": 112, "herbId": "sun_essence_flower", "quality": "uncommon", "obtainedAt": 1771944470410}, {"id": "1771944470410rong50ys1", "name": "五行草", "value": 80, "herbId": "five_elements_grass", "quality": "common", "obtainedAt": 1771944470410}, {"id": "17719444704102m3gc37ad", "name": "月华兰", "value": 140, "herbId": "moonlight_orchid", "quality": "rare", "obtainedAt": 1771944470410}, {"id": "1771944470410vfeu59zjw", "name": "月华兰", "value": 70, "herbId": "moonlight_orchid", "quality": "common", "obtainedAt": 1771944470410}, {"id": "1771944470410brlj0yr44", "name": "月华兰", "value": 105, "herbId": "moonlight_orchid", "quality": "uncommon", "obtainedAt": 1771944470410}, {"id": "1771944470410jabvrjxo7", "name": "日精花", "value": 225, "herbId": "sun_essence_flower", "quality": "epic", "obtainedAt": 1771944470410}, {"id": "1771944470410bc1v11cx8", "name": "月华兰", "value": 105, "herbId": "moonlight_orchid", "quality": "uncommon", "obtainedAt": 1771944470410}, {"id": "1771944470410ayr6kx7xa", "name": "月华兰", "value": 140, "herbId": "moonlight_orchid", "quality": "rare", "obtainedAt": 1771944470410}, {"id": "1771944470410si20ighda", "name": "五行草", "value": 160, "herbId": "five_elements_grass", "quality": "rare", "obtainedAt": 1771944470410}, {"id": "17719444704109gvnqwu9n", "name": "凤羽草", "value": 170, "herbId": "phoenix_feather_herb", "quality": "rare", "obtainedAt": 1771944470410}, {"id": "1771944470410wc1zxq3mx", "name": "五行草", "value": 120, "herbId": "five_elements_grass", "quality": "uncommon", "obtainedAt": 1771944470410}, {"id": "17719444704100pbu40rsy", "name": "五行草", "value": 80, "herbId": "five_elements_grass", "quality": "common", "obtainedAt": 1771944470410}, {"id": "1771944470410cbfse2m1e", "name": "月华兰", "value": 140, "herbId": "moonlight_orchid", "quality": "rare", "obtainedAt": 1771944470410}, {"id": "1771944470410b4ee7dbd3", "name": "天露草", "value": 90, "herbId": "celestial_dew_grass", "quality": "common", "obtainedAt": 1771944470410}, {"id": "1771944470410rxms4bxcp", "name": "五行草", "value": 120, "herbId": "five_elements_grass", "quality": "uncommon", "obtainedAt": 1771944470410}, {"id": "1771944470410rhkmd636m", "name": "月华兰", "value": 140, "herbId": "moonlight_orchid", "quality": "rare", "obtainedAt": 1771944470410}, {"id": "17719444704105wrmydz28", "name": "五行草", "value": 400, "herbId": "five_elements_grass", "quality": "legendary", "obtainedAt": 1771944470410}, {"id": "1771944470410nxf1xx3o6", "name": "凤羽草", "value": 127, "herbId": "phoenix_feather_herb", "quality": "uncommon", "obtainedAt": 1771944470410}, {"id": "1771944470410v2i5cejlq", "name": "日精花", "value": 112, "herbId": "sun_essence_flower", "quality": "uncommon", "obtainedAt": 1771944470410}, {"id": "17719444704103abf2i9vm", "name": "五行草", "value": 240, "herbId": "five_elements_grass", "quality": "epic", "obtainedAt": 1771944470410}, {"id": "1771944470410rdiwu28p9", "name": "五行草", "value": 80, "herbId": "five_elements_grass", "quality": "common", "obtainedAt": 1771944470410}, {"id": "1771944470410ew82bhg4x", "name": "凤羽草", "value": 85, "herbId": "phoenix_feather_herb", "quality": "common", "obtainedAt": 1771944470410}, {"id": "1771944470410jwy45xh8b", "name": "凤羽草", "value": 170, "herbId": "phoenix_feather_herb", "quality": "rare", "obtainedAt": 1771944470410}, {"id": "1771944470410kgwbtbl8q", "name": "月华兰", "value": 140, "herbId": "moonlight_orchid", "quality": "rare", "obtainedAt": 1771944470410}, {"id": "1771944470410d4lqozu94", "name": "日精花", "value": 75, "herbId": "sun_essence_flower", "quality": "common", "obtainedAt": 1771944470410}, {"id": "1771944470410ozv1u1t91", "name": "天露草", "value": 90, "herbId": "celestial_dew_grass", "quality": "common", "obtainedAt": 1771944470410}, {"id": "1771944470410sh8hfn17g", "name": "五行草", "value": 120, "herbId": "five_elements_grass", "quality": "uncommon", "obtainedAt": 1771944470410}, {"id": "1771944470410uoaqucqay", "name": "月华兰", "value": 105, "herbId": "moonlight_orchid", "quality": "uncommon", "obtainedAt": 1771944470410}, {"id": "1771944470410oj36yqgll", "name": "凤羽草", "value": 170, "herbId": "phoenix_feather_herb", "quality": "rare", "obtainedAt": 1771944470410}, {"id": "17719444704107hoiatwrp", "name": "月华兰", "value": 140, "herbId": "moonlight_orchid", "quality": "rare", "obtainedAt": 1771944470410}, {"id": "1771944470410zqoyvmgzo", "name": "天露草", "value": 135, "herbId": "celestial_dew_grass", "quality": "uncommon", "obtainedAt": 1771944470410}, {"id": "177194447041033hcj2gr9", "name": "月华兰", "value": 350, "herbId": "moonlight_orchid", "quality": "legendary", "obtainedAt": 1771944470410}, {"id": "1771944470410q7ym6ol69", "name": "日精花", "value": 75, "herbId": "sun_essence_flower", "quality": "common", "obtainedAt": 1771944470410}], "items": [{"id": 1771607035657.3223, "name": "雷鹰", "star": 1, "type": "pet", "level": 10, "power": 0, "rarity": "mystic", "quality": {"agility": 7, "strength": 6, "constitution": 8, "intelligence": 1}, "deployed": false, "experience": 0, "description": "雷电的猛禽", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 29, "attack": 51, "health": 430, "defense": 18, "critRate": 0.127, "stunRate": 0.138, "comboRate": 0.161, "dodgeRate": 0.104, "healBoost": 0.115, "critResist": 0.104, "stunResist": 0.161, "combatBoost": 0.104, "comboResist": 0.184, "counterRate": 0.173, "dodgeResist": 0.184, "vampireRate": 0.15, "counterResist": 0.161, "vampireResist": 0.092, "critDamageBoost": 0.161, "resistanceBoost": 0.127, "critDamageReduce": 0.104, "finalDamageBoost": 0.138, "finalDamageReduce": 0.138}}, {"id": 1771607035657.3733, "name": "嘲风", "star": 1, "type": "pet", "level": 1, "power": 0, "rarity": "celestial", "quality": {"agility": 1, "strength": 6, "constitution": 4, "intelligence": 5}, "deployed": false, "experience": 0, "description": "龙之三子，形似兽，喜好冒险，常立于殿角", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 32, "attack": 53, "health": 463, "defense": 32, "critRate": 0.16, "stunRate": 0.09, "comboRate": 0.13, "dodgeRate": 0.14, "healBoost": 0.16, "critResist": 0.16, "stunResist": 0.17, "combatBoost": 0.15, "comboResist": 0.11, "counterRate": 0.09, "dodgeResist": 0.16, "vampireRate": 0.18, "counterResist": 0.16, "vampireResist": 0.11, "critDamageBoost": 0.15, "resistanceBoost": 0.14, "critDamageReduce": 0.15, "finalDamageBoost": 0.12, "finalDamageReduce": 0.1}}, {"id": 1771607035657.843, "name": "狻犴", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "celestial", "quality": {"agility": 5, "strength": 10, "constitution": 7, "intelligence": 8}, "deployed": false, "experience": 0, "description": "龙之五子，形似狮子，喜静好坐，常立于香炉", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 31, "attack": 53, "health": 444, "defense": 31, "critRate": 0.13, "stunRate": 0.17, "comboRate": 0.1, "dodgeRate": 0.18, "healBoost": 0.11, "critResist": 0.18, "stunResist": 0.12, "combatBoost": 0.14, "comboResist": 0.14, "counterRate": 0.18, "dodgeResist": 0.16, "vampireRate": 0.14, "counterResist": 0.12, "vampireResist": 0.1, "critDamageBoost": 0.14, "resistanceBoost": 0.17, "critDamageReduce": 0.14, "finalDamageBoost": 0.12, "finalDamageReduce": 0.18}}, {"id": 1771607035657.76, "name": "雷鹰", "star": 2, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 3, "strength": 5, "constitution": 2, "intelligence": 3}, "deployed": false, "experience": 0, "description": "雷电的猛禽", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 26, "attack": 41, "health": 468, "defense": 25, "critRate": 0.106, "stunRate": 0.173, "comboRate": 0.199, "dodgeRate": 0.132, "healBoost": 0.146, "critResist": 0.132, "stunResist": 0.12, "combatBoost": 0.132, "comboResist": 0.146, "counterRate": 0.173, "dodgeResist": 0.159, "vampireRate": 0.12, "counterResist": 0.146, "vampireResist": 0.185, "critDamageBoost": 0.185, "resistanceBoost": 0.185, "critDamageReduce": 0.12, "finalDamageBoost": 0.185, "finalDamageReduce": 0.132}}, {"id": 1771607044467.2766, "name": "蒲牢", "star": 1, "type": "pet", "level": 1, "power": 0, "rarity": "celestial", "quality": {"agility": 5, "strength": 3, "constitution": 3, "intelligence": 3}, "deployed": false, "experience": 0, "description": "龙之四子，形似龙而小，性好鸣，常铸于钟上", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 39, "attack": 55, "health": 501, "defense": 37, "critRate": 0.161, "stunRate": 0.196, "comboRate": 0.15, "dodgeRate": 0.127, "healBoost": 0.196, "critResist": 0.138, "stunResist": 0.173, "combatBoost": 0.115, "comboResist": 0.173, "counterRate": 0.173, "dodgeResist": 0.161, "vampireRate": 0.184, "counterResist": 0.173, "vampireResist": 0.184, "critDamageBoost": 0.184, "resistanceBoost": 0.127, "critDamageReduce": 0.138, "finalDamageBoost": 0.161, "finalDamageReduce": 0.15}}, {"id": 1771607044467.3367, "name": "螭吻", "star": 1, "type": "pet", "level": 1, "power": 0, "rarity": "celestial", "quality": {"agility": 1, "strength": 5, "constitution": 2, "intelligence": 5}, "deployed": false, "experience": 0, "description": "龙之九子，形似鱼，能吞火，常立于屋脊", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 37, "attack": 53, "health": 476, "defense": 29, "critRate": 0.196, "stunRate": 0.115, "comboRate": 0.15, "dodgeRate": 0.161, "healBoost": 0.138, "critResist": 0.127, "stunResist": 0.15, "combatBoost": 0.161, "comboResist": 0.196, "counterRate": 0.173, "dodgeResist": 0.161, "vampireRate": 0.161, "counterResist": 0.15, "vampireResist": 0.161, "critDamageBoost": 0.173, "resistanceBoost": 0.15, "critDamageReduce": 0.161, "finalDamageBoost": 0.15, "finalDamageReduce": 0.15}}, {"id": 1771607044467.0835, "name": "火凤凰", "star": 3, "type": "pet", "level": 40, "power": 0, "rarity": "mystic", "quality": {"agility": 8, "strength": 9, "constitution": 8, "intelligence": 5}, "deployed": false, "experience": 0, "description": "浴火重生的永恒之鸟", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 29, "attack": 47, "health": 876, "defense": 26, "critRate": 0.199, "stunRate": 0.183, "comboRate": 0.199, "dodgeRate": 0.199, "healBoost": 0.168, "critResist": 0.213, "stunResist": 0.229, "combatBoost": 0.183, "comboResist": 0.229, "counterRate": 0.244, "dodgeResist": 0.168, "vampireRate": 0.183, "counterResist": 0.229, "vampireResist": 0.229, "critDamageBoost": 0.138, "resistanceBoost": 0.138, "critDamageReduce": 0.138, "finalDamageBoost": 0.168, "finalDamageReduce": 0.138}}, {"id": 1771607044467.147, "name": "霸下", "star": 2, "type": "pet", "level": 10, "power": 0, "rarity": "celestial", "quality": {"agility": 7, "strength": 9, "constitution": 7, "intelligence": 7}, "deployed": true, "experience": 0, "description": "龙之六子，形似龟，力大无穷，常背负石碑", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 32, "attack": 70, "health": 567, "defense": 30, "critRate": 0.16, "stunRate": 0.1, "comboRate": 0.12, "dodgeRate": 0.17, "healBoost": 0.1, "critResist": 0.11, "stunResist": 0.12, "combatBoost": 0.17, "comboResist": 0.18, "counterRate": 0.1, "dodgeResist": 0.12, "vampireRate": 0.16, "counterResist": 0.14, "vampireResist": 0.12, "critDamageBoost": 0.18, "resistanceBoost": 0.16, "critDamageReduce": 0.17, "finalDamageBoost": 0.14, "finalDamageReduce": 0.15}}, {"id": 1771607044467.4768, "name": "冰狼", "star": 2, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 8, "strength": 6, "constitution": 1, "intelligence": 1}, "deployed": false, "experience": 0, "description": "冰原霸主", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 29, "attack": 60, "health": 474, "defense": 29, "critRate": 0.132, "stunRate": 0.199, "comboRate": 0.159, "dodgeRate": 0.199, "healBoost": 0.146, "critResist": 0.159, "stunResist": 0.106, "combatBoost": 0.199, "comboResist": 0.185, "counterRate": 0.199, "dodgeResist": 0.12, "vampireRate": 0.185, "counterResist": 0.185, "vampireResist": 0.12, "critDamageBoost": 0.146, "resistanceBoost": 0.132, "critDamageReduce": 0.132, "finalDamageBoost": 0.106, "finalDamageReduce": 0.106}}, {"id": 1771611549889.8816, "name": "火凤凰", "star": 2, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 1, "strength": 3, "constitution": 8, "intelligence": 10}, "deployed": false, "experience": 0, "description": "浴火重生的永恒之鸟", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 23, "attack": 37, "health": 338, "defense": 23, "critRate": 0.11, "stunRate": 0.14, "comboRate": 0.16, "dodgeRate": 0.1, "healBoost": 0.15, "critResist": 0.14, "stunResist": 0.13, "combatBoost": 0.13, "comboResist": 0.11, "counterRate": 0.14, "dodgeResist": 0.09, "vampireRate": 0.15, "counterResist": 0.12, "vampireResist": 0.1, "critDamageBoost": 0.11, "resistanceBoost": 0.15, "critDamageReduce": 0.13, "finalDamageBoost": 0.1, "finalDamageReduce": 0.15}}, {"id": 1771611549889.8464, "name": "玄龟", "star": 1, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 7, "strength": 9, "constitution": 2, "intelligence": 10}, "deployed": false, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 16, "attack": 29, "health": 211, "defense": 10, "critRate": 0.11, "stunRate": 0.11, "comboRate": 0.12, "dodgeRate": 0.11, "healBoost": 0.13, "critResist": 0.12, "stunResist": 0.1, "combatBoost": 0.11, "comboResist": 0.11, "counterRate": 0.11, "dodgeResist": 0.1, "vampireRate": 0.14, "counterResist": 0.08, "vampireResist": 0.12, "critDamageBoost": 0.11, "resistanceBoost": 0.08, "critDamageReduce": 0.08, "finalDamageBoost": 0.13, "finalDamageReduce": 0.11}}, {"id": 1771611549889.5383, "name": "冰狼", "star": 2, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 6, "strength": 3, "constitution": 10, "intelligence": 2}, "deployed": false, "experience": 0, "description": "冰原霸主", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 25, "attack": 44, "health": 334, "defense": 17, "critRate": 0.16, "stunRate": 0.14, "comboRate": 0.12, "dodgeRate": 0.14, "healBoost": 0.12, "critResist": 0.1, "stunResist": 0.12, "combatBoost": 0.16, "comboResist": 0.12, "counterRate": 0.11, "dodgeResist": 0.12, "vampireRate": 0.1, "counterResist": 0.08, "vampireResist": 0.15, "critDamageBoost": 0.12, "resistanceBoost": 0.15, "critDamageReduce": 0.12, "finalDamageBoost": 0.11, "finalDamageReduce": 0.14}}, {"id": "pill_sg_1771686644242", "name": "聚灵丹", "type": "pill", "effect": {"type": "spiritRate", "value": 0.2, "duration": 3600, "successRate": 0.9}, "quality": "common", "description": "焰灵恢复+20%，持续60分钟"}, {"id": "pill_cb_1771686644242", "name": "聚气丹", "type": "pill", "effect": {"type": "cultivationRate", "value": 0.3, "duration": 1800, "successRate": 0.8}, "quality": "uncommon", "description": "焰修速度+30%，持续30分钟"}, {"id": "pill_tp_1771686644242", "name": "雷灵丹", "type": "pill", "effect": {"type": "combatBoost", "value": 0.4, "duration": 900, "successRate": 0.7}, "quality": "rare", "description": "战斗属性+40%，持续15分钟"}, {"id": "pill_sr_1771686644242", "name": "回灵丹", "type": "pill", "effect": {"type": "spiritRecovery", "value": 0.4, "duration": 1200, "successRate": 0.8}, "quality": "common", "description": "焰灵恢复+40%，持续20分钟"}, {"id": "spirit_gathering_1771688324022", "name": "聚灵丹", "type": "pill", "effect": {"type": "spiritRate", "value": 0.5, "duration": 3600}, "quality": "common", "description": "提升焰灵恢复速度的焰丹。效果：焰灵恢复+20%，持续60分钟"}, {"id": 1771693284808.8525, "name": "岩龟", "star": 2, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 5, "strength": 6, "constitution": 9, "intelligence": 9}, "deployed": false, "experience": 0, "description": "坚不可摧的守护者", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 27, "attack": 47, "health": 388, "defense": 19, "critRate": 0.15, "stunRate": 0.1, "comboRate": 0.15, "dodgeRate": 0.13, "healBoost": 0.11, "critResist": 0.15, "stunResist": 0.15, "combatBoost": 0.13, "comboResist": 0.16, "counterRate": 0.15, "dodgeResist": 0.1, "vampireRate": 0.11, "counterResist": 0.09, "vampireResist": 0.15, "critDamageBoost": 0.13, "resistanceBoost": 0.09, "critDamageReduce": 0.13, "finalDamageBoost": 0.12, "finalDamageReduce": 0.12}}, {"id": 1771693284896.6238, "name": "雷鹰", "star": 1, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 3, "strength": 2, "constitution": 5, "intelligence": 2}, "deployed": false, "experience": 0, "description": "雷电的猛禽", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 25, "attack": 36, "health": 341, "defense": 17, "critRate": 0.08, "stunRate": 0.16, "comboRate": 0.15, "dodgeRate": 0.09, "healBoost": 0.15, "critResist": 0.15, "stunResist": 0.12, "combatBoost": 0.12, "comboResist": 0.11, "counterRate": 0.11, "dodgeResist": 0.1, "vampireRate": 0.15, "counterResist": 0.14, "vampireResist": 0.09, "critDamageBoost": 0.08, "resistanceBoost": 0.1, "critDamageReduce": 0.1, "finalDamageBoost": 0.1, "finalDamageReduce": 0.12}}, {"id": 1771693650097.4312, "name": "囚牛", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "celestial", "quality": {"agility": 3, "strength": 2, "constitution": 9, "intelligence": 7}, "deployed": false, "experience": 0, "description": "龙之长子，喜好音乐，常立于琴头", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 29, "attack": 49, "health": 458, "defense": 23, "critRate": 0.12, "stunRate": 0.14, "comboRate": 0.15, "dodgeRate": 0.18, "healBoost": 0.09, "critResist": 0.1, "stunResist": 0.14, "combatBoost": 0.1, "comboResist": 0.1, "counterRate": 0.18, "dodgeResist": 0.1, "vampireRate": 0.11, "counterResist": 0.09, "vampireResist": 0.1, "critDamageBoost": 0.1, "resistanceBoost": 0.16, "critDamageReduce": 0.11, "finalDamageBoost": 0.17, "finalDamageReduce": 0.1}}, {"id": 1771693720415.609, "name": "风隼", "star": 2, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 1, "strength": 10, "constitution": 10, "intelligence": 1}, "deployed": false, "experience": 0, "description": "速度极快的飞行焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 13, "attack": 23, "health": 222, "defense": 10, "critRate": 0.12, "stunRate": 0.1, "comboRate": 0.08, "dodgeRate": 0.09, "healBoost": 0.12, "critResist": 0.08, "stunResist": 0.11, "combatBoost": 0.1, "comboResist": 0.1, "counterRate": 0.08, "dodgeResist": 0.11, "vampireRate": 0.14, "counterResist": 0.12, "vampireResist": 0.07, "critDamageBoost": 0.11, "resistanceBoost": 0.12, "critDamageReduce": 0.1, "finalDamageBoost": 0.12, "finalDamageReduce": 0.14}}, {"id": 1771694198345.7568, "name": "狴犴", "star": 1, "type": "pet", "level": 1, "power": 0, "rarity": "celestial", "quality": {"agility": 4, "strength": 3, "constitution": 10, "intelligence": 8}, "deployed": false, "experience": 0, "description": "龙之七子，形似虎，明辨是非，常立于狱门", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 33, "attack": 45, "health": 447, "defense": 29, "critRate": 0.18, "stunRate": 0.15, "comboRate": 0.18, "dodgeRate": 0.15, "healBoost": 0.12, "critResist": 0.14, "stunResist": 0.11, "combatBoost": 0.14, "comboResist": 0.1, "counterRate": 0.1, "dodgeResist": 0.13, "vampireRate": 0.14, "counterResist": 0.14, "vampireResist": 0.16, "critDamageBoost": 0.14, "resistanceBoost": 0.1, "critDamageReduce": 0.12, "finalDamageBoost": 0.17, "finalDamageReduce": 0.18}}, {"id": 1771694198345.9521, "name": "地甲", "star": 3, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 8, "strength": 7, "constitution": 9, "intelligence": 2}, "deployed": false, "experience": 0, "description": "坚固的大地守护者", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 18, "attack": 33, "health": 247, "defense": 11, "critRate": 0.08, "stunRate": 0.12, "comboRate": 0.12, "dodgeRate": 0.1, "healBoost": 0.08, "critResist": 0.09, "stunResist": 0.11, "combatBoost": 0.09, "comboResist": 0.13, "counterRate": 0.11, "dodgeResist": 0.07, "vampireRate": 0.09, "counterResist": 0.11, "vampireResist": 0.08, "critDamageBoost": 0.07, "resistanceBoost": 0.1, "critDamageReduce": 0.09, "finalDamageBoost": 0.13, "finalDamageReduce": 0.09}}, {"id": 1771695140301.1846, "name": "玄龟", "star": 2, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 7, "strength": 8, "constitution": 1, "intelligence": 6}, "deployed": false, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 12, "attack": 31, "health": 230, "defense": 16, "critRate": 0.11, "stunRate": 0.1, "comboRate": 0.12, "dodgeRate": 0.13, "healBoost": 0.09, "critResist": 0.12, "stunResist": 0.11, "combatBoost": 0.1, "comboResist": 0.14, "counterRate": 0.1, "dodgeResist": 0.12, "vampireRate": 0.09, "counterResist": 0.09, "vampireResist": 0.08, "critDamageBoost": 0.08, "resistanceBoost": 0.12, "critDamageReduce": 0.12, "finalDamageBoost": 0.11, "finalDamageReduce": 0.13}}, {"id": 1771695640891.124, "name": "岩龟", "star": 2, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 8, "strength": 6, "constitution": 4, "intelligence": 7}, "deployed": false, "experience": 0, "description": "坚不可摧的守护者", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 19, "attack": 35, "health": 377, "defense": 19, "critRate": 0.08, "stunRate": 0.1, "comboRate": 0.08, "dodgeRate": 0.11, "healBoost": 0.08, "critResist": 0.12, "stunResist": 0.15, "combatBoost": 0.15, "comboResist": 0.1, "counterRate": 0.13, "dodgeResist": 0.09, "vampireRate": 0.12, "counterResist": 0.11, "vampireResist": 0.15, "critDamageBoost": 0.14, "resistanceBoost": 0.16, "critDamageReduce": 0.12, "finalDamageBoost": 0.09, "finalDamageReduce": 0.09}}, {"id": 1771695720218.0251, "name": "地甲", "star": 1, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 5, "strength": 9, "constitution": 6, "intelligence": 3}, "deployed": false, "experience": 0, "description": "坚固的大地守护者", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 16, "attack": 30, "health": 242, "defense": 15, "critRate": 0.13, "stunRate": 0.11, "comboRate": 0.14, "dodgeRate": 0.13, "healBoost": 0.07, "critResist": 0.12, "stunResist": 0.13, "combatBoost": 0.09, "comboResist": 0.07, "counterRate": 0.08, "dodgeResist": 0.07, "vampireRate": 0.13, "counterResist": 0.12, "vampireResist": 0.13, "critDamageBoost": 0.14, "resistanceBoost": 0.11, "critDamageReduce": 0.08, "finalDamageBoost": 0.1, "finalDamageReduce": 0.14}}, {"id": 1771695813019.4695, "name": "玄龟", "star": 1, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 7, "strength": 4, "constitution": 10, "intelligence": 8}, "deployed": false, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 13, "attack": 29, "health": 243, "defense": 13, "critRate": 0.08, "stunRate": 0.08, "comboRate": 0.1, "dodgeRate": 0.1, "healBoost": 0.08, "critResist": 0.11, "stunResist": 0.12, "combatBoost": 0.14, "comboResist": 0.09, "counterRate": 0.12, "dodgeResist": 0.12, "vampireRate": 0.11, "counterResist": 0.13, "vampireResist": 0.11, "critDamageBoost": 0.1, "resistanceBoost": 0.13, "critDamageReduce": 0.11, "finalDamageBoost": 0.13, "finalDamageReduce": 0.13}}, {"id": 1771695957323.8723, "name": "雷鹰", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 8, "strength": 3, "constitution": 3, "intelligence": 2}, "deployed": false, "experience": 0, "description": "雷电的猛禽", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 21, "attack": 42, "health": 320, "defense": 22, "critRate": 0.16, "stunRate": 0.14, "comboRate": 0.14, "dodgeRate": 0.12, "healBoost": 0.12, "critResist": 0.09, "stunResist": 0.11, "combatBoost": 0.16, "comboResist": 0.16, "counterRate": 0.1, "dodgeResist": 0.11, "vampireRate": 0.12, "counterResist": 0.12, "vampireResist": 0.14, "critDamageBoost": 0.12, "resistanceBoost": 0.09, "critDamageReduce": 0.13, "finalDamageBoost": 0.12, "finalDamageReduce": 0.13}}, {"id": 1771695957323.5588, "name": "玄龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 3, "strength": 10, "constitution": 3, "intelligence": 6}, "deployed": false, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 16, "attack": 21, "health": 220, "defense": 15, "critRate": 0.08, "stunRate": 0.07, "comboRate": 0.12, "dodgeRate": 0.13, "healBoost": 0.12, "critResist": 0.08, "stunResist": 0.08, "combatBoost": 0.1, "comboResist": 0.1, "counterRate": 0.11, "dodgeResist": 0.1, "vampireRate": 0.12, "counterResist": 0.12, "vampireResist": 0.09, "critDamageBoost": 0.1, "resistanceBoost": 0.12, "critDamageReduce": 0.11, "finalDamageBoost": 0.09, "finalDamageReduce": 0.11}}, {"id": 1771696163205.0771, "name": "云豹", "star": 2, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 3, "strength": 4, "constitution": 3, "intelligence": 5}, "deployed": false, "experience": 0, "description": "敏捷的猎手", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 17, "attack": 28, "health": 257, "defense": 13, "critRate": 0.09, "stunRate": 0.13, "comboRate": 0.13, "dodgeRate": 0.14, "healBoost": 0.07, "critResist": 0.11, "stunResist": 0.1, "combatBoost": 0.1, "comboResist": 0.08, "counterRate": 0.1, "dodgeResist": 0.1, "vampireRate": 0.13, "counterResist": 0.08, "vampireResist": 0.13, "critDamageBoost": 0.11, "resistanceBoost": 0.12, "critDamageReduce": 0.12, "finalDamageBoost": 0.09, "finalDamageReduce": 0.12}}, {"id": "spirit_gathering_1771696404172", "name": "聚灵丹", "type": "pill", "effect": {"type": "spiritRate", "value": 0.2, "duration": 3600}, "quality": "common", "description": "提升焰灵恢复速度的焰丹。效果：焰灵恢复+20%，持续60分钟"}, {"id": "cultivation_boost_1771696406176", "name": "聚气丹", "type": "pill", "effect": {"type": "cultivationRate", "value": 0.36, "duration": 1800}, "quality": "common", "description": "提升焰修速度的焰丹。效果：焰修速度+30%，持续30分钟"}, {"id": "thunder_power_1771696409727", "name": "雷灵丹", "type": "pill", "effect": {"type": "combatBoost", "value": 0.6000000000000001, "duration": 900}, "quality": "common", "description": "提升战斗属性的焰丹。效果：战斗属性+40%，持续15分钟"}, {"id": "immortal_essence_1771696413687", "name": "仙灵丹", "type": "pill", "effect": {"type": "allAttributes", "value": 1, "duration": 600}, "quality": "common", "description": "全属性提升的神奇焰丹。效果：全属性+50%，持续10分钟"}, {"id": "fire_essence_1771696417447", "name": "火元丹", "type": "pill", "effect": {"type": "fireAttribute", "value": 0.8999999999999999, "duration": 1800}, "quality": "common", "description": "提升火属性焰修速度的焰丹。效果：火属性焰修速度+60%，持续30分钟"}, {"id": "mind_clarity_1771696419574", "name": "清心丹", "type": "pill", "effect": {"type": "comprehension", "value": 0.6, "duration": 2400}, "quality": "common", "description": "提升心境和悟性的焰丹。效果：悟性+30%，持续40分钟"}, {"id": "spirit_recovery_1771696423996", "name": "回灵丹", "type": "pill", "effect": {"type": "spiritRecovery", "value": 0.4, "duration": 1200}, "quality": "common", "description": "快速恢复焰灵的焰丹。效果：焰灵恢复速度+40%，持续20分钟"}, {"id": "essence_condensation_1771696429175", "name": "凝元丹", "type": "pill", "effect": {"type": "cultivationEfficiency", "value": 0.6, "duration": 1500}, "quality": "common", "description": "提升焰修效率的高级焰丹。效果：焰修效率+50%，持续25分钟"}, {"id": 1771704541204.7302, "name": "云霄头部·圣", "slot": "head", "type": "head", "level": 49, "stats": {"health": 738, "defense": 101, "stunResist": 0.12}, "quality": "legendary", "category": "equipment", "equipType": "head", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 2.5, "maxStatMod": 3.5}, "requiredRealm": 49}, {"id": 1771704541204.4248, "name": "玄冥头部·极", "slot": "head", "type": "head", "level": 44, "stats": {"health": 933, "defense": 75, "stunResist": 0.12}, "quality": "epic", "category": "equipment", "equipType": "head", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 44}, {"id": 1771695640891.1904, "name": "天罗手套·极", "slot": "hands", "type": "hands", "level": 1, "stats": {"attack": 12, "critRate": 0.03, "comboRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "hands", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 1}, {"id": 1771695720218.171, "name": "混沌焰杖·极", "slot": "weapon", "type": "weapon", "level": 1, "stats": {"attack": 85, "critRate": 0.04, "critDamageBoost": 0.08}, "quality": "epic", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "enhanceLevel": 8, "requiredRealm": 1}, {"id": "phoenix_rebirth_pill_1771749885414", "name": "涅槃丹", "type": "pill", "effect": {"type": "autoHeal", "value": 1.2000000000000002, "duration": 3600}, "quality": "common", "description": "蕴含不死凤凰之力的神丹，能在战斗中自动恢复生命。效果：战斗中自动恢复10%生命，持续60分钟"}, {"id": "sun_moon_pill_1771749901558", "name": "日月丹", "type": "pill", "effect": {"type": "spiritCap", "value": 9, "duration": 2400}, "quality": "common", "description": "融合日月精华的焰丹，能大幅提升焰灵上限。效果：焰灵上限+150%，持续40分钟"}, {"id": "celestial_essence_pill_1771749905764", "name": "天元丹", "type": "pill", "effect": {"type": "cultivationRate", "value": 7.199999999999999, "duration": 1800}, "quality": "common", "description": "凝聚天地精华的极品焰丹，大幅提升焰修速度。效果：焰修速度+100%，持续30分钟"}, {"id": "five_elements_pill_1771749908877", "name": "五行丹", "type": "pill", "effect": {"type": "allAttributes", "value": 7.200000000000001, "duration": 1200}, "quality": "common", "description": "融合五行之力的神奇焰丹，全面提升焰修者素质。效果：全属性+80%，持续20分钟"}, {"id": 1771846942472.836, "name": "天护肩甲·极", "slot": "shoulder", "type": "shoulder", "level": 53, "stats": {"health": 1137, "defense": 201, "counterRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 53}, {"id": 1771846942472.0354, "name": "混沌焰杖·极", "slot": "weapon", "type": "weapon", "level": 56, "stats": {"attack": 326, "critRate": 0.04, "critDamageBoost": 0.08}, "quality": "epic", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 56}, {"id": 1771846942472.022, "name": "紫命符文戒1·极", "slot": "ring1", "type": "ring1", "level": 58, "stats": {"attack": 260, "critDamageBoost": 0.07, "finalDamageBoost": 0.04}, "quality": "epic", "category": "equipment", "equipType": "ring1", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 58}, {"id": 1771846942472.6165, "name": "赤铜护腕·极", "slot": "wrist", "type": "wrist", "level": 53, "stats": {"defense": 191, "counterRate": 0.04, "vampireRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 53}, {"id": 1771705874651.2534, "name": "九天焰杖·圣", "slot": "weapon", "type": "weapon", "level": 50, "stats": {"attack": 197, "critRate": 0.05, "critDamageBoost": 0.1}, "quality": "legendary", "equipType": "weapon", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 2.5, "maxStatMod": 3.5}, "requiredRealm": 50}, {"id": 1771704541204.8755, "name": "赤霞头部·极", "slot": "head", "type": "head", "level": 48, "stats": {"health": 961, "defense": 103, "stunResist": 0.12}, "quality": "epic", "category": "equipment", "equipType": "head", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 48}, {"id": 1771704541204.7185, "name": "天护肩甲·仙", "slot": "shoulder", "type": "shoulder", "level": 49, "stats": {"health": 853, "defense": 139, "counterRate": 0.06}, "quality": "mythic", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "仙品", "color": "#e91e63", "statMod": 3, "maxStatMod": 4}, "requiredRealm": 49}, {"id": 1771704541204.0178, "name": "赤铜护腕·圣", "slot": "wrist", "type": "wrist", "level": 45, "stats": {"defense": 85, "counterRate": 0.05, "vampireRate": 0.05}, "quality": "legendary", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 2.5, "maxStatMod": 3.5}, "requiredRealm": 45}, {"id": 1771947781028.079, "name": "云纱护腕·极", "slot": "wrist", "type": "wrist", "level": 66, "stats": {"defense": 167, "counterRate": 0.04, "vampireRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 66}, {"id": 1771947793188.5198, "name": "赤命符文戒1·圣", "slot": "ring1", "type": "ring1", "level": 65, "stats": {"attack": 366, "critDamageBoost": 0.09, "finalDamageBoost": 0.05}, "quality": "legendary", "category": "equipment", "equipType": "ring1", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 6, "maxStatMod": 8}, "requiredRealm": 65}, {"id": 1771947814103.2214, "name": "云踪鞋子·极", "slot": "feet", "type": "feet", "level": 70, "stats": {"speed": 289, "defense": 230, "dodgeRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "feet", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 70}, {"id": 1771947814103.2034, "name": "幽影鞋子·极", "slot": "feet", "type": "feet", "level": 64, "stats": {"speed": 257, "defense": 170, "dodgeRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "feet", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 64}, {"id": 1771947814103.717, "name": "星步鞋子·极", "slot": "feet", "type": "feet", "level": 62, "stats": {"speed": 334, "defense": 180, "dodgeRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "feet", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 62}, {"id": 1771947814103.062, "name": "玄阳衣服·极", "slot": "body", "type": "body", "level": 65, "stats": {"health": 3164, "defense": 357, "finalDamageReduce": 0.12}, "quality": "epic", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 65}, {"id": 1771704541204.0503, "name": "星光裤子·极", "slot": "legs", "type": "legs", "level": 42, "stats": {"speed": 95, "defense": 112, "dodgeRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 42}, {"id": 1771704541204.2964, "name": "天行鞋子·真", "slot": "feet", "type": "feet", "level": 43, "stats": {"speed": 98, "defense": 43, "dodgeRate": 0.03}, "quality": "rare", "category": "equipment", "equipType": "feet", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 1.5, "maxStatMod": 2.5}, "requiredRealm": 43}, {"id": 1771846942472.5024, "name": "玄甲肩甲·极", "slot": "shoulder", "type": "shoulder", "level": 61, "stats": {"health": 1822, "defense": 274, "counterRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 61}, {"id": 1771704541204.7039, "name": "紫晶手套·仙", "slot": "hands", "type": "hands", "level": 50, "stats": {"attack": 159, "critRate": 0.04, "comboRate": 0.06}, "quality": "mythic", "category": "equipment", "equipType": "hands", "qualityInfo": {"name": "仙品", "color": "#e91e63", "statMod": 3, "maxStatMod": 4}, "requiredRealm": 50}, {"id": 1771846942472.381, "name": "紫玉护腕·圣", "slot": "wrist", "type": "wrist", "level": 54, "stats": {"defense": 198, "counterRate": 0.05, "vampireRate": 0.05}, "quality": "legendary", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 6, "maxStatMod": 8}, "requiredRealm": 54}, {"id": 1771846942472.6626, "name": "云命符文戒1·圣", "slot": "ring1", "type": "ring1", "level": 56, "stats": {"attack": 274, "critDamageBoost": 0.09, "finalDamageBoost": 0.05}, "quality": "legendary", "category": "equipment", "equipType": "ring1", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 6, "maxStatMod": 8}, "requiredRealm": 56}, {"id": 1771704541204.8923, "name": "天道符文戒2·圣", "slot": "ring2", "type": "ring2", "level": 48, "stats": {"defense": 108, "resistanceBoost": 0.05, "critDamageReduce": 0.09}, "quality": "legendary", "category": "equipment", "equipType": "ring2", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 2.5, "maxStatMod": 3.5}, "requiredRealm": 48}, {"id": 1771704541204.1484, "name": "玄系腰带·仙", "slot": "belt", "type": "belt", "level": 49, "stats": {"health": 1095, "defense": 74, "combatBoost": 0.06}, "quality": "mythic", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "仙品", "color": "#e91e63", "statMod": 3, "maxStatMod": 4}, "requiredRealm": 49}, {"id": 1771982815636.7957, "name": "云甲肩甲·初", "slot": "shoulder", "type": "shoulder", "level": 68, "stats": {"health": 605, "defense": 89, "counterRate": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.5, "maxStatMod": 2}, "requiredRealm": 68}], "level": 74, "pills": [], "realm": "渡焰二重", "spirit": 7600, "herbRate": 1, "isGMMode": false, "vipLevel": 0, "activePet": {"id": 1771607044467.147, "name": "霸下", "star": 2, "type": "pet", "level": 10, "power": 0, "rarity": "celestial", "quality": {"agility": 7, "strength": 9, "constitution": 7, "intelligence": 7}, "deployed": true, "experience": 0, "description": "龙之六子，形似龟，力大无穷，常背负石碑", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 32, "attack": 70, "health": 567, "defense": 30, "critRate": 0.16, "stunRate": 0.1, "comboRate": 0.12, "dodgeRate": 0.17, "healBoost": 0.1, "critResist": 0.11, "stunResist": 0.12, "combatBoost": 0.17, "comboResist": 0.18, "counterRate": 0.1, "dodgeResist": 0.12, "vampireRate": 0.16, "counterResist": 0.14, "vampireResist": 0.12, "critDamageBoost": 0.18, "resistanceBoost": 0.16, "critDamageReduce": 0.17, "finalDamageBoost": 0.14, "finalDamageReduce": 0.15}}, "artifacts": [], "petConfig": {"rarityMap": {"divine": {"name": "神品", "color": "#FF0000", "probability": 0.02, "essenceBonus": 50}, "mortal": {"name": "凡品", "color": "#32CD32", "probability": 0.5, "essenceBonus": 5}, "mystic": {"name": "玄品", "color": "#9932CC", "probability": 0.15, "essenceBonus": 20}, "celestial": {"name": "仙品", "color": "#FFD700", "probability": 0.08, "essenceBonus": 30}, "spiritual": {"name": "灵品", "color": "#1E90FF", "probability": 0.25, "essenceBonus": 10}}}, "realmName": "化焰五重", "wheelGame": {"lastDate": "2026-02-25", "spinCount": 1}, "_nakedBase": {"speed": 475, "attack": 2112, "health": 21120, "defense": 1284}, "isDarkMode": false, "itemsFound": 0, "petEssence": 65, "realmIndex": 49, "spiritRate": 265456074.83329195, "alchemyRate": 1, "cultivation": 89392, "isNewPlayer": false, "pillRecipes": [], "lastTickTime": 1771991008084, "pillsCrafted": 4, "spiritStones": 302003, "activeEffects": [], "pillFragments": {"thunder_power": 1, "spirit_recovery": 2, "spirit_gathering": 3, "cultivation_boost": 2}, "pillsConsumed": 1, "storageExpand": {"pet": 1, "herb": 1, "formula": 1}, "baseAttributes": {"speed": 1013, "attack": 3448, "health": 33667, "defense": 3485}, "eventTriggered": 0, "lastOnlineTime": 1771988513355, "maxCultivation": 132000, "purchasedPacks": ["pack_starter"], "unlockedRealms": ["燃火一层", "大焰三重", "大焰四重", "大焰五重", "大焰六重", "大焰七重", "大焰八重", "大焰九重", "渡焰一重", "渡焰二重"], "unlockedSkills": [], "artifactBonuses": {"speed": 517, "attack": 1246, "health": 12197, "defense": 2166, "critRate": 0.14, "stunRate": 0, "comboRate": 0.08, "dodgeRate": 0.08, "healBoost": 0.07, "critResist": 0, "spiritRate": 0.07, "stunResist": 0.12, "combatBoost": 0.04, "comboResist": 0, "counterRate": 0.09, "dodgeResist": 0, "vampireRate": 0.05, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0.16999999999999998, "cultivationRate": 0, "resistanceBoost": 0.04, "critDamageReduce": 0.07, "finalDamageBoost": 0.05, "finalDamageReduce": 0.12}, "cultivationRate": 1, "nameChangeCount": 1, "reinforceStones": 43, "wishlistEnabled": false, "activeMountBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "activeTitleBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "combatAttributes": {"critRate": 0.14, "stunRate": 0, "comboRate": 0.08, "dodgeRate": 0.08, "counterRate": 0.09, "vampireRate": 0.05}, "combatResistance": {"critResist": 0, "stunResist": 0.12, "comboResist": 0, "dodgeResist": 0, "counterResist": 0, "vampireResist": 0}, "dungeonBossKills": 3, "dungeonTotalRuns": 0, "explorationCount": 9, "refinementStones": 7, "autoSellQualities": [], "breakthroughCount": 20, "dungeonDeathCount": 0, "dungeonDifficulty": 1, "dungeonEliteKills": 4, "dungeonTotalKills": 39, "equippedArtifacts": {"belt": {"id": 1771947814103.454, "name": "青系腰带·仙", "slot": "belt", "type": "belt", "level": 69, "stats": {"health": 1403, "defense": 207, "combatBoost": 0.04}, "quality": "epic", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 69}, "body": {"id": 1771846942472.5728, "name": "赤凤衣服·仙", "slot": "body", "type": "body", "level": 53, "stats": {"health": 3464, "defense": 375, "finalDamageReduce": 0.12}, "quality": "epic", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 53}, "feet": {"id": 1771947814103.9165, "name": "紫霞鞋子·仙", "slot": "feet", "type": "feet", "level": 61, "stats": {"speed": 362, "defense": 175, "dodgeRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "feet", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 61}, "head": {"id": 1771846942472.0234, "name": "青玉头部·圣", "slot": "head", "type": "head", "level": 62, "stats": {"health": 2478, "defense": 343, "stunResist": 0.12}, "quality": "legendary", "category": "equipment", "equipType": "head", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 6, "maxStatMod": 8}, "requiredRealm": 62}, "legs": {"id": 1771938014225.4658, "name": "紫电裤子·仙", "slot": "legs", "type": "legs", "level": 67, "stats": {"speed": 155, "defense": 220, "dodgeRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 67}, "hands": {"id": 1771947814103.8193, "name": "紫晶手套·仙", "slot": "hands", "type": "hands", "level": 62, "stats": {"attack": 174, "critRate": 0.03, "comboRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "hands", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 62}, "ring1": {"id": 1771947793188.2927, "name": "天命符文戒1·圣", "slot": "ring1", "type": "ring1", "level": 71, "stats": {"attack": 367, "critDamageBoost": 0.09, "finalDamageBoost": 0.05}, "quality": "legendary", "category": "equipment", "equipType": "ring1", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 6, "maxStatMod": 8}, "requiredRealm": 71}, "ring2": {"id": 1771947814103.2275, "name": "星道符文戒2·仙", "slot": "ring2", "type": "ring2", "level": 64, "stats": {"defense": 245, "resistanceBoost": 0.04, "critDamageReduce": 0.07}, "quality": "epic", "category": "equipment", "equipType": "ring2", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 64}, "wrist": {"id": 1771947814103.883, "name": "青石护腕·圣", "slot": "wrist", "type": "wrist", "level": 70, "stats": {"defense": 349, "counterRate": 0.05, "vampireRate": 0.05}, "quality": "legendary", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 6, "maxStatMod": 8}, "requiredRealm": 70}, "weapon": {"id": 1771870822641.1128, "name": "太虚焰杖·仙", "slot": "weapon", "type": "weapon", "level": 54, "stats": {"attack": 702, "critRate": 0.04, "critDamageBoost": 0.08}, "quality": "epic", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "enhanceLevel": 6, "requiredRealm": 54}, "artifact": {"id": 1771704541204.5774, "name": "赤宝焰器·仙", "slot": "artifact", "type": "artifact", "level": 42, "stats": {"attack": 3, "critRate": 0.07, "comboRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "artifact", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 42}, "necklace": {"id": 1771846942472.5771, "name": "星魂焰心链·仙", "slot": "necklace", "type": "necklace", "level": 60, "stats": {"health": 2683, "healBoost": 0.07, "spiritRate": 0.07}, "quality": "epic", "category": "equipment", "equipType": "necklace", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 60}, "shoulder": {"id": 1771938665053.1423, "name": "云甲肩甲·仙", "slot": "shoulder", "type": "shoulder", "level": 58, "stats": {"health": 2169, "defense": 252, "counterRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 4, "maxStatMod": 5.5}, "requiredRealm": 58}}, "isAutoCultivating": false, "specialAttributes": {"healBoost": 0.07, "combatBoost": 0.04, "critDamageBoost": 0.16999999999999998, "resistanceBoost": 0.04, "critDamageReduce": 0.07, "finalDamageBoost": 0.05, "finalDamageReduce": 0.12}, "unlockedLocations": ["新手村"], "autoReleaseRarities": [], "dungeonHighestFloor": 39, "dungeonTotalRewards": 22117, "shopWeeklyPurchases": {"legendary": {"count": 1, "weekStart": 1771200000000}}, "unlockedPillRecipes": 0, "totalCultivationTime": 804, "completedAchievements": ["equipment_1", "equipment_2", "equipment_3", "equipment_7", "dungeon_2", "dungeon_3", "dungeon_4", "dungeon_combat_1", "cultivation_1", "collection_1", "collection_2", "collection_3", "collection_4", "collection_5", "collection_6", "collection_10", "resources_1", "resources_2", "resources_3", "resources_4", "resources_5", "resources_6", "resources_7", "equipment_6", "breakthrough_1", "breakthrough_2"], "dungeonHighestFloor_2": 0, "dungeonHighestFloor_5": 0, "selectedWishPetRarity": null, "dungeonHighestFloor_10": 0, "dungeonLastFailedFloor": 0, "dungeonHighestFloor_100": 14, "selectedWishEquipQuality": null}	5	1015.00000000	310877	74	渡焰二重	52869	t	2026-02-24	1	2026-02-18 08:26:57.865876	2026-02-24 22:43:28.104984	f	409
15	0xc385d64735689929311621f4e81ca5b4e7830055	无名焰修	{"luck": 1, "name": "测试 2", "buffs": {}, "herbs": [], "items": [{"id": 1771704541204.6682, "name": "星晶护腕·极", "slot": "wrist", "type": "wrist", "level": 43, "stats": {"defense": 65, "counterRate": 0.04, "vampireRate": 0.04}, "quality": "epic", "category": "equipment", "equipType": "wrist", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 43}, {"id": 1771694198345.4775, "name": "赤炎焰杖·圣", "slot": "weapon", "type": "weapon", "level": 1, "stats": {"attack": 38, "critRate": 0.05, "critDamageBoost": 0.1}, "quality": "legendary", "category": "equipment", "equipType": "weapon", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 2.5, "maxStatMod": 3.5}, "requiredRealm": 1}, {"id": 1771681436107.8853, "name": "星系腰带·极", "slot": "belt", "type": "belt", "level": 1, "stats": {"health": 175, "defense": 15, "combatBoost": 0.04}, "quality": "epic", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "上品", "color": "#9c27b0", "statMod": 2, "maxStatMod": 3}, "requiredRealm": 1}, {"id": "pill_ie_1771686644242", "name": "仙灵丹", "type": "pill", "effect": {"type": "allAttributes", "value": 0.5, "duration": 600, "successRate": 0.6}, "quality": "epic", "description": "全属性+50%，持续10分钟"}, {"id": 1771848880990.532, "name": "紫霞鞋子·初", "slot": "feet", "type": "feet", "level": 21, "stats": {"speed": 59, "defense": 34, "dodgeRate": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "feet", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.5, "maxStatMod": 2}, "requiredRealm": 21}], "level": 24, "pills": [], "realm": "凝焰六重", "spirit": 4813, "herbRate": 1, "isGMMode": false, "vipLevel": 0, "activePet": null, "artifacts": [], "gachaPity": {"petCount": 1, "equipCount": 1}, "petConfig": {"rarityMap": {"divine": {"name": "神品", "color": "#FF0000", "probability": 0.02, "essenceBonus": 50}, "mortal": {"name": "凡品", "color": "#32CD32", "probability": 0.5, "essenceBonus": 5}, "mystic": {"name": "玄品", "color": "#9932CC", "probability": 0.15, "essenceBonus": 20}, "celestial": {"name": "仙品", "color": "#FFD700", "probability": 0.08, "essenceBonus": 30}, "spiritual": {"name": "灵品", "color": "#1E90FF", "probability": 0.25, "essenceBonus": 10}}}, "_nakedBase": {"speed": 13, "attack": 20, "health": 150, "defense": 15}, "isDarkMode": false, "itemsFound": 0, "petEssence": 0, "spiritRate": 1, "alchemyRate": 1, "cultivation": 2412, "isNewPlayer": true, "pillRecipes": [], "lastTickTime": 1771848915752, "pillsCrafted": 0, "spiritStones": 2394990, "activeEffects": [], "pillFragments": {}, "pillsConsumed": 0, "storageExpand": {}, "baseAttributes": {"speed": 300, "attack": 740, "health": 7450, "defense": 565}, "eventTriggered": 0, "lastOnlineTime": 1771848915752, "maxCultivation": 6100, "unlockedRealms": ["燃火一层"], "unlockedSkills": [], "artifactBonuses": {"speed": 0, "attack": 0, "health": 0, "defense": 0, "critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "healBoost": 0, "critResist": 0, "spiritRate": 0, "stunResist": 0, "combatBoost": 0, "comboResist": 0, "counterRate": 0, "dodgeResist": 0, "vampireRate": 0, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0, "cultivationRate": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "cultivationRate": 1, "lastExploreTime": 1771848915668, "nameChangeCount": 1, "reinforceStones": 23, "wishlistEnabled": false, "activeMountBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "activeTitleBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "combatAttributes": {"critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "counterRate": 0, "vampireRate": 0}, "combatResistance": {"critResist": 0, "stunResist": 0, "comboResist": 0, "dodgeResist": 0, "counterResist": 0, "vampireResist": 0}, "dungeonBossKills": 0, "dungeonTotalRuns": 0, "explorationCount": 2, "refinementStones": 0, "autoSellQualities": [], "breakthroughCount": 3, "dungeonDeathCount": 0, "dungeonDifficulty": 1, "dungeonEliteKills": 0, "dungeonTotalKills": 0, "equippedArtifacts": {}, "isAutoCultivating": false, "specialAttributes": {"healBoost": 0, "combatBoost": 0, "critDamageBoost": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "unlockedLocations": ["新手村"], "autoReleaseRarities": [], "dungeonHighestFloor": 0, "dungeonTotalRewards": 0, "unlockedPillRecipes": 0, "totalCultivationTime": 0, "completedAchievements": [], "dungeonHighestFloor_2": 0, "dungeonHighestFloor_5": 0, "selectedWishPetRarity": null, "dungeonHighestFloor_10": 0, "dungeonLastFailedFloor": 0, "dungeonHighestFloor_100": 0, "selectedWishEquipQuality": null}	3	234.00000000	2394990	24	凝焰六重	225	t	2026-02-23	1	2026-02-22 05:40:05.985095	2026-02-23 07:15:15.752904	f	268
5	0xa40d60613f61e8546a9e3348b1f31630443485ba	无名修士	{"name": "无名修士", "spirit": 300, "spiritStones": 200000}	0	0.00000000	200000	1	燃火期一层	0	f	\N	0	2026-02-19 11:23:29.400245	2026-02-19 11:23:29.400245	f	0
17	0x7c402b2d8c7d48414d5f1eb4dd6522d04992c023	野猪佩奇	{"luck": 1, "name": "野猪佩奇", "buffs": {}, "herbs": [], "items": [], "level": 1, "pills": [], "realm": "燃火期一层", "spirit": 300, "herbRate": 1, "isGMMode": false, "vipLevel": 0, "activePet": null, "artifacts": [], "petConfig": {"rarityMap": {"divine": {"name": "神品", "color": "#FF0000", "probability": 0.02, "essenceBonus": 50}, "mortal": {"name": "凡品", "color": "#32CD32", "probability": 0.5, "essenceBonus": 5}, "mystic": {"name": "玄品", "color": "#9932CC", "probability": 0.15, "essenceBonus": 20}, "celestial": {"name": "仙品", "color": "#FFD700", "probability": 0.08, "essenceBonus": 30}, "spiritual": {"name": "灵品", "color": "#1E90FF", "probability": 0.25, "essenceBonus": 10}}}, "isDarkMode": false, "itemsFound": 0, "petEssence": 0, "spiritRate": 1.05, "alchemyRate": 1, "cultivation": 51, "isNewPlayer": true, "pillRecipes": [], "pillsCrafted": 0, "spiritStones": 100000, "activeEffects": [], "pillFragments": {}, "pillsConsumed": 0, "storageExpand": {}, "baseAttributes": {"speed": 10, "attack": 10, "health": 100, "defense": 5}, "eventTriggered": 0, "lastOnlineTime": 1771781058028, "maxCultivation": 100, "unlockedRealms": ["燃火一层", "燃火一重"], "unlockedSkills": [], "artifactBonuses": {"speed": 0, "attack": 0, "health": 0, "defense": 0, "critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "healBoost": 0, "critResist": 0, "spiritRate": 0, "stunResist": 0, "combatBoost": 0, "comboResist": 0, "counterRate": 0, "dodgeResist": 0, "vampireRate": 0, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0, "cultivationRate": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "cultivationRate": 1, "nameChangeCount": 1, "reinforceStones": 0, "wishlistEnabled": false, "activeMountBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "activeTitleBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "combatAttributes": {"critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "counterRate": 0, "vampireRate": 0}, "combatResistance": {"critResist": 0, "stunResist": 0, "comboResist": 0, "dodgeResist": 0, "counterResist": 0, "vampireResist": 0}, "dungeonBossKills": 0, "dungeonTotalRuns": 0, "explorationCount": 0, "refinementStones": 0, "autoSellQualities": [], "breakthroughCount": 0, "dungeonDeathCount": 0, "dungeonDifficulty": 1, "dungeonEliteKills": 0, "dungeonTotalKills": 0, "equippedArtifacts": {}, "isAutoCultivating": false, "specialAttributes": {"healBoost": 0, "combatBoost": 0, "critDamageBoost": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "unlockedLocations": ["新手村"], "autoReleaseRarities": [], "dungeonHighestFloor": 0, "dungeonTotalRewards": 0, "unlockedPillRecipes": 0, "totalCultivationTime": 705, "completedAchievements": [], "dungeonHighestFloor_2": 0, "dungeonHighestFloor_5": 0, "selectedWishPetRarity": null, "dungeonHighestFloor_10": 0, "dungeonLastFailedFloor": 0, "dungeonHighestFloor_100": 0, "selectedWishEquipQuality": null}	0	0.00000000	100000	1	燃火期一层	325	f	\N	0	2026-02-22 12:24:16.478798	2026-02-22 12:35:04.527318	f	26
22	0xbot002	焰影·寒霜	{"items": [], "level": 74, "realm": "大焰九重", "spirit": 1000, "cultivation": 50000, "spiritStones": 10000, "maxCultivation": 100000, "combatAttributes": {"speed": 5500, "attack": 16500, "health": 110000, "defense": 8250, "critRate": 0.15, "dodgeRate": 0.05, "critDamage": 0.5, "vampireRate": 0.03}}	0	0.00000000	10000	74	大焰九重	55000	f	\N	0	2026-02-24 13:15:37.19313	2026-02-24 13:15:37.19313	f	0
23	0xbot003	焰影·雷鸣	{"items": [], "level": 70, "realm": "大焰八重", "spirit": 1000, "cultivation": 50000, "spiritStones": 10000, "maxCultivation": 100000, "combatAttributes": {"speed": 4800, "attack": 14400, "health": 96000, "defense": 7200, "critRate": 0.15, "dodgeRate": 0.05, "critDamage": 0.5, "vampireRate": 0.03}}	0	0.00000000	10000	70	大焰八重	48000	f	\N	0	2026-02-24 13:15:37.196987	2026-02-24 13:15:37.196987	f	0
24	0xbot004	焰影·星辰	{"items": [], "level": 76, "realm": "焰合一重", "spirit": 1000, "cultivation": 50000, "spiritStones": 10000, "maxCultivation": 100000, "combatAttributes": {"speed": 6200, "attack": 18600, "health": 124000, "defense": 9300, "critRate": 0.15, "dodgeRate": 0.05, "critDamage": 0.5, "vampireRate": 0.03}}	0	0.00000000	10000	76	焰合一重	62000	f	\N	0	2026-02-24 13:15:37.200388	2026-02-24 13:15:37.200388	f	0
25	0xbot005	焰影·幽冥	{"items": [], "level": 65, "realm": "大焰六重", "spirit": 1000, "cultivation": 50000, "spiritStones": 10000, "maxCultivation": 100000, "combatAttributes": {"speed": 4000, "attack": 12000, "health": 80000, "defense": 6000, "critRate": 0.15, "dodgeRate": 0.05, "critDamage": 0.5, "vampireRate": 0.03}}	0	0.00000000	10000	65	大焰六重	40000	f	\N	0	2026-02-24 13:15:37.203242	2026-02-24 13:15:37.203242	f	0
26	0xbot006	焰影·天罡	{"items": [], "level": 72, "realm": "大焰九重", "spirit": 1000, "cultivation": 50000, "spiritStones": 10000, "maxCultivation": 100000, "combatAttributes": {"speed": 5200, "attack": 15600, "health": 104000, "defense": 7800, "critRate": 0.15, "dodgeRate": 0.05, "critDamage": 0.5, "vampireRate": 0.03}}	0	0.00000000	10000	72	大焰九重	52000	f	\N	0	2026-02-24 13:15:37.206373	2026-02-24 13:15:37.206373	f	0
27	0xbot007	焰影·玄武	{"items": [], "level": 78, "realm": "焰合二重", "spirit": 1000, "cultivation": 50000, "spiritStones": 10000, "maxCultivation": 100000, "combatAttributes": {"speed": 6800, "attack": 20400, "health": 136000, "defense": 10200, "critRate": 0.15, "dodgeRate": 0.05, "critDamage": 0.5, "vampireRate": 0.03}}	0	0.00000000	10000	78	焰合二重	68000	f	\N	0	2026-02-24 13:15:37.208681	2026-02-24 13:15:37.208681	f	0
14	0x53b07cbaefe27255578c912a9dde76bbf0f3ca16	测试焰修	{"spirit": 300, "_nakedBase": {"speed": 10, "attack": 10, "health": 100, "defense": 5}, "spiritStones": 100000, "baseAttributes": {"speed": 10, "attack": 10, "health": 100, "defense": 5}, "artifactBonuses": {"speed": 0, "attack": 0, "health": 0, "defense": 0, "critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "healBoost": 0, "critResist": 0, "spiritRate": 0, "stunResist": 0, "combatBoost": 0, "comboResist": 0, "counterRate": 0, "dodgeResist": 0, "vampireRate": 0, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0, "cultivationRate": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "combatAttributes": {"critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "counterRate": 0, "vampireRate": 0}, "combatResistance": {"critResist": 0, "stunResist": 0, "comboResist": 0, "dodgeResist": 0, "counterResist": 0, "vampireResist": 0}, "equippedArtifacts": {}, "specialAttributes": {"healBoost": 0, "combatBoost": 0, "critDamageBoost": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}}	0	0.00000000	100000	1	燃火期一层	0	f	\N	0	2026-02-22 00:55:16.552731	2026-02-22 00:55:16.667676	f	4
9	0xbot0000000000000000000000000000000000a1	剑魔·青锋	{"luck": 1, "name": "无名修士", "buffs": {"luckyCharm": 1771745064015}, "herbs": [{"id": "1771658626396e2zbml26r", "name": "玄阴草", "value": 45, "herbId": "dark_yin_grass", "quality": "uncommon", "obtainedAt": 1771658626396}, {"id": "17716586263966n4f9uhtr", "name": "灵精草", "value": 20, "herbId": "spirit_grass", "quality": "rare", "obtainedAt": 1771658626396}, {"id": "1771658626396iwxu42e2n", "name": "云雾花", "value": 15, "herbId": "cloud_flower", "quality": "common", "obtainedAt": 1771658626396}, {"id": "1771658626396ab2hzecgo", "name": "玄阴草", "value": 45, "herbId": "dark_yin_grass", "quality": "uncommon", "obtainedAt": 1771658626396}, {"id": "1771658626396zl59brtjb", "name": "玄阴草", "value": 30, "herbId": "dark_yin_grass", "quality": "common", "obtainedAt": 1771658626396}, {"id": "1771658626396cke9ekm2e", "name": "雷击根", "value": 50, "herbId": "thunder_root", "quality": "rare", "obtainedAt": 1771658626396}, {"id": "1771658626396ar1fia4n6", "name": "火心花", "value": 35, "herbId": "fire_heart_flower", "quality": "common", "obtainedAt": 1771658626396}, {"id": "1771658626396fn5n2wy9r", "name": "云雾花", "value": 15, "herbId": "cloud_flower", "quality": "common", "obtainedAt": 1771658626396}, {"id": "1771658626396pv4y85ka7", "name": "云雾花", "value": 15, "herbId": "cloud_flower", "quality": "common", "obtainedAt": 1771658626396}, {"id": "1771658626396x28ickbjp", "name": "雷击根", "value": 25, "herbId": "thunder_root", "quality": "common", "obtainedAt": 1771658626397}, {"id": "17716586263970s6k4juch", "name": "雷击根", "value": 50, "herbId": "thunder_root", "quality": "rare", "obtainedAt": 1771658626397}, {"id": "1771658626397o3z2hmm0j", "name": "雷击根", "value": 37, "herbId": "thunder_root", "quality": "uncommon", "obtainedAt": 1771658626397}, {"id": "177165862639770lwg9hz2", "name": "雷击根", "value": 25, "herbId": "thunder_root", "quality": "common", "obtainedAt": 1771658626397}, {"id": "1771658626397ogk9a4mu3", "name": "云雾花", "value": 15, "herbId": "cloud_flower", "quality": "common", "obtainedAt": 1771658626397}, {"id": "1771658626397f9xk2xnag", "name": "火心花", "value": 105, "herbId": "fire_heart_flower", "quality": "epic", "obtainedAt": 1771658626397}, {"id": "17716586263970kj7uxswf", "name": "雷击根", "value": 25, "herbId": "thunder_root", "quality": "common", "obtainedAt": 1771658626397}, {"id": "1771658626397v88647c0x", "name": "云雾花", "value": 22, "herbId": "cloud_flower", "quality": "uncommon", "obtainedAt": 1771658626397}, {"id": "1771658626397b7y17kcpq", "name": "火心花", "value": 35, "herbId": "fire_heart_flower", "quality": "common", "obtainedAt": 1771658626397}, {"id": "fire_heart_flower", "name": "火心花", "value": 35, "herbId": "fire_heart_flower", "herb_id": "fire_heart_flower", "quality": "common", "obtainedAt": 1771658685041}, {"id": "1771662181838b9ubxexh5", "name": "灵精草", "value": 10, "herbId": "spirit_grass", "quality": "common", "obtainedAt": 1771662181838}, {"id": "1771662181838hp8woc5ht", "name": "云雾花", "value": 22, "herbId": "cloud_flower", "quality": "uncommon", "obtainedAt": 1771662181838}, {"id": "1771662181838owk101mvl", "name": "玄阴草", "value": 30, "herbId": "dark_yin_grass", "quality": "common", "obtainedAt": 1771662181838}, {"id": "1771662181838g5zy1vaxz", "name": "火心花", "value": 35, "herbId": "fire_heart_flower", "quality": "common", "obtainedAt": 1771662181838}, {"id": "1771662181838s8zrkajm5", "name": "雷击根", "value": 25, "herbId": "thunder_root", "quality": "common", "obtainedAt": 1771662181838}, {"id": "1771662181838c0vm1oxwr", "name": "灵精草", "value": 10, "herbId": "spirit_grass", "quality": "common", "obtainedAt": 1771662181838}, {"id": "1771662181838exbnltl54", "name": "玄阴草", "value": 30, "herbId": "dark_yin_grass", "quality": "common", "obtainedAt": 1771662181838}, {"id": "1771662181838z3v2za7xq", "name": "云雾花", "value": 15, "herbId": "cloud_flower", "quality": "common", "obtainedAt": 1771662181838}, {"id": "1771662181838nopx5q1zu", "name": "云雾花", "value": 15, "herbId": "cloud_flower", "quality": "common", "obtainedAt": 1771662181838}, {"id": "1771662181838fjilixf5a", "name": "玄阴草", "value": 45, "herbId": "dark_yin_grass", "quality": "uncommon", "obtainedAt": 1771662181838}, {"id": "1771662181838zy3o5bl7t", "name": "雷击根", "value": 25, "herbId": "thunder_root", "quality": "common", "obtainedAt": 1771662181838}, {"id": "1771662181838l1iaouv5q", "name": "灵精草", "value": 10, "herbId": "spirit_grass", "quality": "common", "obtainedAt": 1771662181838}, {"id": "1771662181838ku312hua5", "name": "灵精草", "value": 20, "herbId": "spirit_grass", "quality": "rare", "obtainedAt": 1771662181838}, {"id": "17716621818383xjkswend", "name": "灵精草", "value": 15, "herbId": "spirit_grass", "quality": "uncommon", "obtainedAt": 1771662181838}, {"id": "17716621818389f26vzw3y", "name": "云雾花", "value": 22, "herbId": "cloud_flower", "quality": "uncommon", "obtainedAt": 1771662181838}, {"id": "1771662181838r5i9hm8xk", "name": "云雾花", "value": 22, "herbId": "cloud_flower", "quality": "uncommon", "obtainedAt": 1771662181838}], "items": [{"id": 1771671308815.9092, "name": "火鼠", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 9, "strength": 8, "constitution": 10, "intelligence": 1}, "experience": 0, "description": "活泼的啮齿类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 14, "health": 114, "defense": 6, "critRate": 0.08, "stunRate": 0.05, "comboRate": 0.1, "dodgeRate": 0.07, "healBoost": 0.06, "critResist": 0.09, "stunResist": 0.07, "combatBoost": 0.09, "comboResist": 0.07, "counterRate": 0.1, "dodgeResist": 0.07, "vampireRate": 0.05, "counterResist": 0.08, "vampireResist": 0.09, "critDamageBoost": 0.09, "resistanceBoost": 0.1, "critDamageReduce": 0.08, "finalDamageBoost": 0.07, "finalDamageReduce": 0.07}}], "level": 50, "pills": [], "realm": "焰虚五重", "spirit": 5200, "herbRate": 1, "isGMMode": false, "activePet": null, "artifacts": [], "gachaPity": {"petCount": 2, "equipCount": 2}, "petConfig": {"rarityMap": {"divine": {"name": "神品", "color": "#FF0000", "probability": 0.02, "essenceBonus": 50}, "mortal": {"name": "凡品", "color": "#32CD32", "probability": 0.5, "essenceBonus": 5}, "mystic": {"name": "玄品", "color": "#9932CC", "probability": 0.15, "essenceBonus": 20}, "celestial": {"name": "仙品", "color": "#FFD700", "probability": 0.08, "essenceBonus": 30}, "spiritual": {"name": "灵品", "color": "#1E90FF", "probability": 0.25, "essenceBonus": 10}}}, "isDarkMode": false, "itemsFound": 0, "petEssence": 1135, "spiritRate": 3.45, "alchemyRate": 1, "cultivation": 0, "isNewPlayer": true, "pillRecipes": ["spirit_gathering"], "pillsCrafted": 0, "spiritStones": 5104715, "activeEffects": [], "pillFragments": {}, "pillsConsumed": 0, "storageExpand": {"equip": 1}, "baseAttributes": {"speed": 500, "attack": 8000, "health": 50000, "defense": 3000}, "eventTriggered": 0, "lastOnlineTime": 1771670931996, "maxCultivation": 26000, "unlockedRealms": ["练气一层"], "unlockedSkills": [], "artifactBonuses": {"speed": 0, "attack": 0, "health": 0, "defense": 0, "critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "healBoost": 0, "critResist": 0, "spiritRate": 1, "stunResist": 0, "combatBoost": 0, "comboResist": 0, "counterRate": 0, "dodgeResist": 0, "vampireRate": 0, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0, "cultivationRate": 1, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "cultivationRate": 1, "nameChangeCount": 0, "reinforceStones": 503, "wishlistEnabled": false, "activeMountBonus": {"speed_bonus": 0.1, "attack_bonus": 0.05, "health_bonus": 0.05, "defense_bonus": 0.03}, "activeTitleBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "combatAttributes": {"critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "counterRate": 0, "vampireRate": 0}, "combatResistance": {"critResist": 0, "stunResist": 0, "comboResist": 0, "dodgeResist": 0, "counterResist": 0, "vampireResist": 0}, "dungeonBossKills": 1, "dungeonTotalRuns": 0, "explorationCount": 0, "refinementStones": 196, "autoSellQualities": [], "breakthroughCount": 0, "dungeonDeathCount": 0, "dungeonDifficulty": 1, "dungeonEliteKills": 2, "dungeonTotalKills": 5, "equippedArtifacts": {"belt": null, "body": null, "feet": null, "head": null, "legs": null, "hands": null, "ring1": null, "ring2": null, "wrist": null, "weapon": null, "artifact": null, "necklace": null, "shoulder": null}, "specialAttributes": {"healBoost": 0, "combatBoost": 0, "critDamageBoost": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "unlockedLocations": ["新手村"], "autoReleaseRarities": [], "dungeonHighestFloor": 10, "dungeonTotalRewards": 670, "unlockedPillRecipes": 0, "totalCultivationTime": 35, "completedAchievements": ["cultivation_1", "resources_1", "resources_2", "resources_3", "resources_4", "resources_5", "resources_6", "resources_7", "resources_8"], "dungeonHighestFloor_2": 0, "dungeonHighestFloor_5": 5, "selectedWishPetRarity": null, "dungeonHighestFloor_10": 0, "dungeonLastFailedFloor": 0, "dungeonHighestFloor_100": 0, "selectedWishEquipQuality": null}	0	0.00000000	5104715	50	焰虚五重	999999	f	\N	0	2026-02-20 23:34:08.010864	2026-02-21 05:49:28.336774	f	0
16	0x602faa4d15c6df9468fbffb44618cf21834d231b	无名焰修	{"luck": 1, "name": "无名焰修", "buffs": {}, "herbs": [], "items": [], "level": 1, "pills": [], "realm": "燃火期一层", "spirit": 300, "herbRate": 1, "isGMMode": false, "vipLevel": 0, "activePet": null, "artifacts": [], "petConfig": {"rarityMap": {"divine": {"name": "神品", "color": "#FF0000", "probability": 0.02, "essenceBonus": 50}, "mortal": {"name": "凡品", "color": "#32CD32", "probability": 0.5, "essenceBonus": 5}, "mystic": {"name": "玄品", "color": "#9932CC", "probability": 0.15, "essenceBonus": 20}, "celestial": {"name": "仙品", "color": "#FFD700", "probability": 0.08, "essenceBonus": 30}, "spiritual": {"name": "灵品", "color": "#1E90FF", "probability": 0.25, "essenceBonus": 10}}}, "isDarkMode": false, "itemsFound": 0, "petEssence": 0, "spiritRate": 1.1, "alchemyRate": 1, "cultivation": 63, "isNewPlayer": true, "pillRecipes": [], "pillsCrafted": 0, "spiritStones": 100000, "activeEffects": [], "pillFragments": {}, "pillsConsumed": 0, "storageExpand": {}, "baseAttributes": {"speed": 10, "attack": 10, "health": 100, "defense": 5}, "eventTriggered": 0, "lastOnlineTime": 1771773300636, "maxCultivation": 100, "unlockedRealms": ["燃火一层", "燃火一重", "燃火二重"], "unlockedSkills": [], "artifactBonuses": {"speed": 0, "attack": 0, "health": 0, "defense": 0, "critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "healBoost": 0, "critResist": 0, "spiritRate": 0, "stunResist": 0, "combatBoost": 0, "comboResist": 0, "counterRate": 0, "dodgeResist": 0, "vampireRate": 0, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0, "cultivationRate": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "cultivationRate": 1, "nameChangeCount": 0, "reinforceStones": 0, "wishlistEnabled": false, "activeMountBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "activeTitleBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "combatAttributes": {"critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "counterRate": 0, "vampireRate": 0}, "combatResistance": {"critResist": 0, "stunResist": 0, "comboResist": 0, "dodgeResist": 0, "counterResist": 0, "vampireResist": 0}, "dungeonBossKills": 0, "dungeonTotalRuns": 0, "explorationCount": 0, "refinementStones": 0, "autoSellQualities": [], "breakthroughCount": 0, "dungeonDeathCount": 0, "dungeonDifficulty": 1, "dungeonEliteKills": 0, "dungeonTotalKills": 0, "equippedArtifacts": {}, "isAutoCultivating": true, "specialAttributes": {"healBoost": 0, "combatBoost": 0, "critDamageBoost": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "unlockedLocations": ["新手村"], "autoReleaseRarities": [], "dungeonHighestFloor": 0, "dungeonTotalRewards": 0, "unlockedPillRecipes": 0, "totalCultivationTime": 253, "completedAchievements": [], "dungeonHighestFloor_2": 0, "dungeonHighestFloor_5": 0, "selectedWishPetRarity": null, "dungeonHighestFloor_10": 0, "dungeonLastFailedFloor": 0, "dungeonHighestFloor_100": 0, "selectedWishEquipQuality": null}	0	0.00000000	100000	1	燃火期一层	425	f	\N	0	2026-02-22 08:29:25.584743	2026-02-22 14:13:43.614963	f	10
12	0xbot0000000000000000000000000000000000d4	小焰·新手	{"name": "鬼修·幽冥", "items": [{"id": 1771671442491.5056, "name": "混沌焰杖·圣", "slot": "weapon", "type": "weapon", "level": 14, "stats": {"attack": 77, "critRate": 0.05, "critDamageBoost": 0.1}, "quality": "legendary", "equipType": "weapon", "qualityInfo": {"name": "极品", "color": "#ff9800", "statMod": 2.5, "maxStatMod": 3.5}, "requiredRealm": 14}, {"id": 1771671516229.6143, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 6, "strength": 9, "constitution": 10, "intelligence": 5}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 7, "attack": 14, "health": 113, "defense": 6, "critRate": 0.09, "stunRate": 0.07, "comboRate": 0.09, "dodgeRate": 0.09, "healBoost": 0.05, "critResist": 0.06, "stunResist": 0.07, "combatBoost": 0.08, "comboResist": 0.06, "counterRate": 0.08, "dodgeResist": 0.09, "vampireRate": 0.09, "counterResist": 0.1, "vampireResist": 0.06, "critDamageBoost": 0.09, "resistanceBoost": 0.09, "critDamageReduce": 0.06, "finalDamageBoost": 0.07, "finalDamageReduce": 0.06}}], "level": 10, "realm": "铸炉一重", "spirit": 1200, "gachaPity": {"petCount": 1, "equipCount": 1}, "petEssence": 5, "realmIndex": 13, "spiritRate": 1.45, "cultivation": 45000, "spiritStones": 474900, "baseAttributes": {"speed": 80, "attack": 500, "health": 3000, "defense": 200}, "maxCultivation": 1700, "reinforceStones": 0, "shopWeeklyPurchases": {"legendary": {"count": 1, "weekStart": 1771218000000}}}	0	0.00000000	474900	10	铸炉一重	10000	f	2026-02-21	1	2026-02-20 23:40:20.125482	2026-02-21 05:55:11.855344	f	0
28	0xbot008	焰影·朱雀	{"items": [], "level": 71, "realm": "大焰九重", "spirit": 1000, "cultivation": 50000, "spiritStones": 10000, "maxCultivation": 100000, "combatAttributes": {"speed": 5000, "attack": 15000, "health": 100000, "defense": 7500, "critRate": 0.15, "dodgeRate": 0.05, "critDamage": 0.5, "vampireRate": 0.03}}	0	0.00000000	10000	71	大焰九重	50000	f	\N	0	2026-02-24 13:15:37.211307	2026-02-24 13:15:37.211307	f	0
18	0x2f3a3513f2973a66e26850cc7a1baab6363d1b8f	索罗斯二世	{"luck": 1, "name": "索罗斯二世", "buffs": {}, "herbs": [], "items": [{"id": 1771839663274.363, "name": "紫系腰带", "slot": "belt", "type": "belt", "level": 1, "stats": {"health": 45, "defense": 6, "combatBoost": 0.02}, "quality": "common", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 1}, {"id": 1771839683084.798, "name": "云系腰带", "slot": "belt", "type": "belt", "level": 1, "stats": {"health": 87, "defense": 8, "combatBoost": 0.02}, "quality": "common", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 1}, {"id": 1771839683084.0608, "name": "赤系腰带·初", "slot": "belt", "type": "belt", "level": 1, "stats": {"health": 79, "defense": 10, "combatBoost": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.5, "maxStatMod": 2}, "requiredRealm": 1}, {"id": 1771839683084.8425, "name": "赤命符文戒1", "slot": "ring1", "type": "ring1", "level": 1, "stats": {"attack": 7, "critDamageBoost": 0.04, "finalDamageBoost": 0.02}, "quality": "common", "category": "equipment", "equipType": "ring1", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 1}, {"id": 1771839702977.107, "name": "草兔", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 8, "strength": 4, "constitution": 10, "intelligence": 3}, "experience": 0, "description": "温顺的兔类焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 12, "health": 118, "defense": 7, "critRate": 0.05, "stunRate": 0.09, "comboRate": 0.07, "dodgeRate": 0.1, "healBoost": 0.05, "critResist": 0.06, "stunResist": 0.08, "combatBoost": 0.07, "comboResist": 0.08, "counterRate": 0.07, "dodgeResist": 0.08, "vampireRate": 0.05, "counterResist": 0.08, "vampireResist": 0.1, "critDamageBoost": 0.09, "resistanceBoost": 0.06, "critDamageReduce": 0.06, "finalDamageBoost": 0.1, "finalDamageReduce": 0.1}}, {"id": 1771839702977.2437, "name": "玄龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 5, "strength": 1, "constitution": 9, "intelligence": 6}, "experience": 0, "description": "擅长防御的水系焰兽", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 13, "attack": 25, "health": 218, "defense": 14, "critRate": 0.09, "stunRate": 0.09, "comboRate": 0.12, "dodgeRate": 0.08, "healBoost": 0.09, "critResist": 0.09, "stunResist": 0.1, "combatBoost": 0.13, "comboResist": 0.1, "counterRate": 0.13, "dodgeResist": 0.09, "vampireRate": 0.14, "counterResist": 0.09, "vampireResist": 0.1, "critDamageBoost": 0.11, "resistanceBoost": 0.08, "critDamageReduce": 0.13, "finalDamageBoost": 0.13, "finalDamageReduce": 0.1}}, {"id": 1771839702977.138, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 2, "strength": 9, "constitution": 2, "intelligence": 8}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 14, "health": 112, "defense": 6, "critRate": 0.09, "stunRate": 0.07, "comboRate": 0.1, "dodgeRate": 0.07, "healBoost": 0.09, "critResist": 0.08, "stunResist": 0.08, "combatBoost": 0.08, "comboResist": 0.06, "counterRate": 0.08, "dodgeResist": 0.06, "vampireRate": 0.08, "counterResist": 0.08, "vampireResist": 0.09, "critDamageBoost": 0.05, "resistanceBoost": 0.07, "critDamageReduce": 0.08, "finalDamageBoost": 0.08, "finalDamageReduce": 0.09}}, {"id": 1771839702977.847, "name": "岩龟", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 1, "strength": 8, "constitution": 5, "intelligence": 7}, "experience": 0, "description": "坚不可摧的守护者", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 22, "attack": 39, "health": 356, "defense": 18, "critRate": 0.09, "stunRate": 0.12, "comboRate": 0.09, "dodgeRate": 0.1, "healBoost": 0.15, "critResist": 0.14, "stunResist": 0.11, "combatBoost": 0.14, "comboResist": 0.1, "counterRate": 0.1, "dodgeResist": 0.09, "vampireRate": 0.09, "counterResist": 0.12, "vampireResist": 0.08, "critDamageBoost": 0.16, "resistanceBoost": 0.1, "critDamageReduce": 0.09, "finalDamageBoost": 0.14, "finalDamageReduce": 0.11}}, {"id": 1771839702977.815, "name": "灵猫", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 3, "strength": 7, "constitution": 4, "intelligence": 3}, "experience": 0, "description": "敏捷的小型焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 12, "health": 114, "defense": 8, "critRate": 0.06, "stunRate": 0.05, "comboRate": 0.09, "dodgeRate": 0.09, "healBoost": 0.06, "critResist": 0.1, "stunResist": 0.09, "combatBoost": 0.07, "comboResist": 0.09, "counterRate": 0.07, "dodgeResist": 0.06, "vampireRate": 0.09, "counterResist": 0.09, "vampireResist": 0.08, "critDamageBoost": 0.09, "resistanceBoost": 0.06, "critDamageReduce": 0.09, "finalDamageBoost": 0.07, "finalDamageReduce": 0.06}}, {"id": 1771839702977.535, "name": "灵猫", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 4, "strength": 10, "constitution": 8, "intelligence": 8}, "experience": 0, "description": "敏捷的小型焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 11, "health": 108, "defense": 7, "critRate": 0.06, "stunRate": 0.1, "comboRate": 0.06, "dodgeRate": 0.07, "healBoost": 0.09, "critResist": 0.08, "stunResist": 0.07, "combatBoost": 0.1, "comboResist": 0.09, "counterRate": 0.06, "dodgeResist": 0.05, "vampireRate": 0.06, "counterResist": 0.08, "vampireResist": 0.07, "critDamageBoost": 0.05, "resistanceBoost": 0.09, "critDamageReduce": 0.06, "finalDamageBoost": 0.09, "finalDamageReduce": 0.08}}, {"id": 1771839702977.9946, "name": "幻蝶", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mortal", "quality": {"agility": 6, "strength": 2, "constitution": 4, "intelligence": 3}, "experience": 0, "description": "美丽的蝴蝶焰兽", "upgradeItems": 1, "maxExperience": 100, "combatAttributes": {"speed": 8, "attack": 14, "health": 119, "defense": 7, "critRate": 0.08, "stunRate": 0.06, "comboRate": 0.05, "dodgeRate": 0.07, "healBoost": 0.08, "critResist": 0.06, "stunResist": 0.09, "combatBoost": 0.1, "comboResist": 0.08, "counterRate": 0.07, "dodgeResist": 0.1, "vampireRate": 0.06, "counterResist": 0.08, "vampireResist": 0.06, "critDamageBoost": 0.07, "resistanceBoost": 0.09, "critDamageReduce": 0.06, "finalDamageBoost": 0.07, "finalDamageReduce": 0.06}}, {"id": 1771839702977.7983, "name": "云豹", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "spiritual", "quality": {"agility": 3, "strength": 3, "constitution": 4, "intelligence": 2}, "experience": 0, "description": "敏捷的猎手", "upgradeItems": 2, "maxExperience": 100, "combatAttributes": {"speed": 14, "attack": 27, "health": 222, "defense": 12, "critRate": 0.09, "stunRate": 0.13, "comboRate": 0.09, "dodgeRate": 0.14, "healBoost": 0.11, "critResist": 0.1, "stunResist": 0.08, "combatBoost": 0.11, "comboResist": 0.09, "counterRate": 0.14, "dodgeResist": 0.08, "vampireRate": 0.11, "counterResist": 0.12, "vampireResist": 0.1, "critDamageBoost": 0.07, "resistanceBoost": 0.1, "critDamageReduce": 0.1, "finalDamageBoost": 0.08, "finalDamageReduce": 0.1}}, {"id": 1771839702977.5496, "name": "嘲风", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "celestial", "quality": {"agility": 10, "strength": 10, "constitution": 2, "intelligence": 2}, "experience": 0, "description": "龙之三子，形似兽，喜好冒险，常立于殿角", "upgradeItems": 4, "maxExperience": 100, "combatAttributes": {"speed": 27, "attack": 45, "health": 436, "defense": 31, "critRate": 0.1, "stunRate": 0.12, "comboRate": 0.14, "dodgeRate": 0.15, "healBoost": 0.18, "critResist": 0.17, "stunResist": 0.15, "combatBoost": 0.15, "comboResist": 0.1, "counterRate": 0.16, "dodgeResist": 0.17, "vampireRate": 0.12, "counterResist": 0.13, "vampireResist": 0.11, "critDamageBoost": 0.16, "resistanceBoost": 0.12, "critDamageReduce": 0.13, "finalDamageBoost": 0.16, "finalDamageReduce": 0.14}}, {"id": 1771839702977.12, "name": "雷鹰", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 8, "strength": 1, "constitution": 8, "intelligence": 7}, "experience": 0, "description": "雷电的猛禽", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 21, "attack": 36, "health": 339, "defense": 16, "critRate": 0.12, "stunRate": 0.13, "comboRate": 0.09, "dodgeRate": 0.15, "healBoost": 0.1, "critResist": 0.12, "stunResist": 0.08, "combatBoost": 0.11, "comboResist": 0.15, "counterRate": 0.09, "dodgeResist": 0.15, "vampireRate": 0.11, "counterResist": 0.16, "vampireResist": 0.09, "critDamageBoost": 0.12, "resistanceBoost": 0.13, "critDamageReduce": 0.1, "finalDamageBoost": 0.11, "finalDamageReduce": 0.12}}], "level": 2, "pills": [], "realm": "燃火二重", "spirit": 400, "herbRate": 1, "isGMMode": false, "vipLevel": 0, "activePet": null, "artifacts": [], "petConfig": {"rarityMap": {"divine": {"name": "神品", "color": "#FF0000", "probability": 0.02, "essenceBonus": 50}, "mortal": {"name": "凡品", "color": "#32CD32", "probability": 0.5, "essenceBonus": 5}, "mystic": {"name": "玄品", "color": "#9932CC", "probability": 0.15, "essenceBonus": 20}, "celestial": {"name": "仙品", "color": "#FFD700", "probability": 0.08, "essenceBonus": 30}, "spiritual": {"name": "灵品", "color": "#1E90FF", "probability": 0.25, "essenceBonus": 10}}}, "_nakedBase": {"speed": 10, "attack": 10, "health": 100, "defense": 5}, "isDarkMode": false, "itemsFound": 0, "petEssence": 115, "spiritRate": 1, "alchemyRate": 1, "cultivation": 168, "isNewPlayer": true, "pillRecipes": [], "lastTickTime": 1771857182605, "pillsCrafted": 0, "spiritStones": 111850, "activeEffects": [], "pillFragments": {}, "pillsConsumed": 0, "storageExpand": {}, "baseAttributes": {"speed": 22, "attack": 44, "health": 721, "defense": 68}, "eventTriggered": 0, "lastOnlineTime": 0, "maxCultivation": 200, "unlockedRealms": ["燃火一层"], "unlockedSkills": [], "artifactBonuses": {"speed": 12, "attack": 34, "health": 621, "defense": 63, "critRate": 0.03, "stunRate": 0, "comboRate": 0.03, "dodgeRate": 0.02, "healBoost": 0.04, "critResist": 0, "spiritRate": 0.05, "stunResist": 0, "combatBoost": 0.04, "comboResist": 0, "counterRate": 0.03, "dodgeResist": 0, "vampireRate": 0, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0.09, "cultivationRate": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0.05, "finalDamageReduce": 0.25}, "cultivationRate": 1, "nameChangeCount": 1, "reinforceStones": 20, "wishlistEnabled": false, "activeMountBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "activeTitleBonus": {"speed_bonus": 0, "attack_bonus": 0, "health_bonus": 0, "defense_bonus": 0}, "combatAttributes": {"critRate": 0.03, "stunRate": 0, "comboRate": 0.03, "dodgeRate": 0.02, "counterRate": 0.03, "vampireRate": 0}, "combatResistance": {"critResist": 0, "stunResist": 0, "comboResist": 0, "dodgeResist": 0, "counterResist": 0, "vampireResist": 0}, "dungeonBossKills": 0, "dungeonTotalRuns": 0, "explorationCount": 0, "refinementStones": 0, "autoSellQualities": [], "breakthroughCount": 1, "dungeonDeathCount": 0, "dungeonDifficulty": 1, "dungeonEliteKills": 0, "dungeonTotalKills": 0, "equippedArtifacts": {"belt": {"id": 1771839683084.0752, "name": "紫系腰带·道", "slot": "belt", "type": "belt", "level": 1, "stats": {"health": 103, "defense": 10, "combatBoost": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "belt", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.5, "maxStatMod": 2}, "requiredRealm": 1}, "body": {"id": 1771839683084.9338, "name": "混元衣服·天", "slot": "body", "type": "body", "level": 1, "stats": {"health": 318, "defense": 38, "finalDamageReduce": 0.12}, "quality": "rare", "category": "equipment", "equipType": "body", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 2.5, "maxStatMod": 3.5}, "requiredRealm": 1}, "feet": {"id": 1771839683084.0916, "name": "紫霞鞋子", "slot": "feet", "type": "feet", "level": 1, "stats": {"speed": 12, "defense": 6, "dodgeRate": 0.02}, "quality": "common", "category": "equipment", "equipType": "feet", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 1}, "hands": {"id": 1771839683084.6914, "name": "紫晶手套·道", "slot": "hands", "type": "hands", "level": 1, "stats": {"attack": 12, "critRate": 0.02, "comboRate": 0.02}, "quality": "uncommon", "category": "equipment", "equipType": "hands", "qualityInfo": {"name": "下品", "color": "#4caf50", "statMod": 1.5, "maxStatMod": 2}, "requiredRealm": 1}, "ring1": {"id": 1771839683084.4546, "name": "星命符文戒1·天", "slot": "ring1", "type": "ring1", "level": 1, "stats": {"attack": 22, "critDamageBoost": 0.06, "finalDamageBoost": 0.03}, "quality": "rare", "category": "equipment", "equipType": "ring1", "qualityInfo": {"name": "中品", "color": "#2196f3", "statMod": 2.5, "maxStatMod": 3.5}, "requiredRealm": 1}, "necklace": {"id": 1771839683084.151, "name": "云珠焰心链", "slot": "necklace", "type": "necklace", "level": 1, "stats": {"health": 115, "healBoost": 0.04, "spiritRate": 0.04}, "quality": "common", "category": "equipment", "equipType": "necklace", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 1}, "shoulder": {"id": 1771839683084.7969, "name": "幽岚肩甲", "slot": "shoulder", "type": "shoulder", "level": 1, "stats": {"health": 85, "defense": 9, "counterRate": 0.02}, "quality": "common", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 1}}, "isAutoCultivating": false, "specialAttributes": {"healBoost": 0.04, "combatBoost": 0.04, "critDamageBoost": 0.09, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0.05, "finalDamageReduce": 0.25}, "unlockedLocations": ["新手村"], "autoReleaseRarities": [], "dungeonHighestFloor": 0, "dungeonTotalRewards": 0, "unlockedPillRecipes": 0, "totalCultivationTime": 0, "completedAchievements": [], "dungeonHighestFloor_2": 0, "dungeonHighestFloor_5": 0, "selectedWishPetRarity": null, "dungeonHighestFloor_10": 0, "dungeonLastFailedFloor": 0, "dungeonHighestFloor_100": 0, "selectedWishEquipQuality": null}	0	0.00000000	111850	2	燃火二重	1895	f	\N	0	2026-02-23 04:31:48.192975	2026-02-23 09:33:02.607192	f	60
10	0xbot0000000000000000000000000000000000b2	血影·魔尊	{"name": "药仙·白露", "items": [{"id": 1771656525094.8723, "name": "幽岚肩甲", "slot": "shoulder", "type": "shoulder", "level": 15, "stats": {"health": 131, "defense": 24, "counterRate": 0.02}, "quality": "common", "category": "equipment", "equipType": "shoulder", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 15}, {"id": 1771671516178.0571, "name": "紫电裤子", "slot": "legs", "type": "legs", "level": 6, "stats": {"speed": 15, "defense": 16, "dodgeRate": 0.02}, "quality": "common", "category": "equipment", "equipType": "legs", "qualityInfo": {"name": "凡品", "color": "#9e9e9e", "statMod": 1, "maxStatMod": 1.5}, "requiredRealm": 6}], "level": 35, "realm": "焰婴八重", "spirit": 3700, "gachaPity": {"petCount": 1, "equipCount": 1}, "petEssence": 0, "realmIndex": 12, "spiritRate": 2.7, "cultivation": 35000, "spiritStones": 1094910, "baseAttributes": {"speed": 300, "attack": 4000, "health": 25000, "defense": 1500}, "maxCultivation": 13000, "reinforceStones": 0, "dungeonTotalKills": 1, "dungeonHighestFloor": 1, "dungeonTotalRewards": 10}	0	0.00000000	1094910	35	焰婴八重	500000	f	\N	0	2026-02-20 23:34:08.010864	2026-02-20 23:34:08.010864	f	0
3	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	无名修士	{"name": "无名修士", "level": 1, "spirit": 300, "_nakedBase": {"speed": 10, "attack": 10, "health": 100, "defense": 5}, "cultivation": 64, "lastTickTime": 1771960453797, "spiritStones": 205816, "baseAttributes": {"speed": 10, "attack": 10, "health": 100, "defense": 5}, "lastOnlineTime": 1771960238072, "maxCultivation": 100, "artifactBonuses": {"speed": 0, "attack": 0, "health": 0, "defense": 0, "critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "healBoost": 0, "critResist": 0, "spiritRate": 0, "stunResist": 0, "combatBoost": 0, "comboResist": 0, "counterRate": 0, "dodgeResist": 0, "vampireRate": 0, "counterResist": 0, "vampireResist": 0, "critDamageBoost": 0, "cultivationRate": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}, "reinforceStones": 10, "combatAttributes": {"critRate": 0, "stunRate": 0, "comboRate": 0, "dodgeRate": 0, "counterRate": 0, "vampireRate": 0}, "combatResistance": {"critResist": 0, "stunResist": 0, "comboResist": 0, "dodgeResist": 0, "counterResist": 0, "vampireResist": 0}, "equippedArtifacts": {}, "specialAttributes": {"healBoost": 0, "combatBoost": 0, "critDamageBoost": 0, "resistanceBoost": 0, "critDamageReduce": 0, "finalDamageBoost": 0, "finalDamageReduce": 0}}	0	0.00000000	205816	1	燃火期一层	0	f	2026-02-19	1	2026-02-18 10:51:03.127196	2026-02-24 14:14:13.809915	f	0
11	0xbot0000000000000000000000000000000000c3	云游·散人	{"items": [{"id": 1771672463536.4858, "name": "雷鹰", "star": 0, "type": "pet", "level": 1, "power": 0, "rarity": "mystic", "quality": {"agility": 8, "strength": 8, "constitution": 4, "intelligence": 1}, "experience": 0, "description": "雷电的猛禽", "upgradeItems": 3, "maxExperience": 100, "combatAttributes": {"speed": 25, "attack": 34, "health": 325, "defense": 20, "critRate": 0.13, "stunRate": 0.13, "comboRate": 0.09, "dodgeRate": 0.12, "healBoost": 0.09, "critResist": 0.11, "stunResist": 0.14, "combatBoost": 0.13, "comboResist": 0.09, "counterRate": 0.12, "dodgeResist": 0.13, "vampireRate": 0.14, "counterResist": 0.1, "vampireResist": 0.15, "critDamageBoost": 0.1, "resistanceBoost": 0.12, "critDamageReduce": 0.08, "finalDamageBoost": 0.11, "finalDamageReduce": 0.13}}], "level": 20, "realm": "凝焰二重", "spirit": 2200, "petEssence": 20, "spiritRate": 1.95, "cultivation": 500, "spiritStones": 906460, "maxCultivation": 4300, "reinforceStones": 0, "dungeonBossKills": 1, "dungeonTotalKills": 6, "dungeonHighestFloor": 100, "dungeonTotalRewards": 4010}	0	0.00000000	906460	20	凝焰二重	100000	f	2026-02-21	1	2026-02-20 23:40:14.253813	2026-02-21 07:33:48.252527	f	0
\.


--
-- Data for Name: private_messages; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.private_messages (id, from_wallet, to_wallet, content, is_read, created_at) FROM stdin;
3	0x82e402b05f3e936b63a874788c73e1552657c4f7	0xbot0000000000000000000000000000000000a1	哈咯	f	2026-02-21 08:13:46.773259
1	0xbot0000000000000000000000000000000000a1	0xbot0000000000000000000000000000000000c3	你好c3，这是私聊测试	t	2026-02-21 05:58:41.721007
2	0xbot0000000000000000000000000000000000a1	0xbot0000000000000000000000000000000000c3	测试非好友私聊	f	2026-02-21 05:59:18.275133
4	0xbot0000000000000000000000000000000000a1	0x82e402b05f3e936b63a874788c73e1552657c4f7	哈咯兄弟！青锋在此，有何贵干？⚔️	t	2026-02-21 08:14:45.89832
\.


--
-- Data for Name: recharge_log; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.recharge_log (id, wallet, tx_hash, amount, spirit_stones, bonus_stones, created_at) FROM stdin;
1	0xadb0ecf47e175089579da5182dd7707328575909	0xef6fc04775f428fa0d7651239cad2d97fa83473af3fc01c304d3e732fdf08505	1.00000000	20000	10000	2026-02-17 14:49:39.38778
2	0xadb0ecf47e175089579da5182dd7707328575909	0x4b39ac61102b89c16c3b8f40612001d9e163a30cacee19cb7932ed8e04904b53	1.00000000	10000	0	2026-02-18 12:04:58.380965
3	0x82e402b05f3e936b63a874788c73e1552657c4f7	0x775404a68dd58eac091c5f8a636d0716a339c0021240a11b6aa7a6a98babc178	10.00000000	200000	100000	2026-02-21 15:07:22.616013
4	0x82e402b05f3e936b63a874788c73e1552657c4f7	0xd4a688f96cd154568776541030ef739b2823b4e9fc119f05c7d4be447b3a021d	5.00000000	50000	0	2026-02-21 15:08:35.63209
5	0xc385d64735689929311621f4e81ca5b4e7830055	0xd193e5d8cf92f10a05fc6d8337868d327b9d618c9048a3d6d3f606afdeb74b6b	100.00000000	2000000	1000000	2026-02-22 05:40:45.545571
6	0xc385d64735689929311621f4e81ca5b4e7830055	0x215c5f323455df48fc16ff1cbec949e2da4c2cafe070138c0265ceb84be5c379	100.00000000	1000000	0	2026-02-22 05:56:42.668678
7	0xc385d64735689929311621f4e81ca5b4e7830055	0xec4484f2c3ec91de0ac4294368234fdcacd5684185cab86c4134decc90af652c	34.00000000	340000	0	2026-02-22 09:04:31.133775
\.


--
-- Data for Name: sect_members; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.sect_members (id, sect_id, wallet, role, contribution, joined_at) FROM stdin;
8	1	0xc385d64735689929311621f4e81ca5b4e7830055	member	0	2026-02-22 19:49:59.783934
9	3	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	leader	0	2026-02-24 13:35:15.242004
7	1	0x82e402b05f3e936b63a874788c73e1552657c4f7	member	748	2026-02-21 14:59:35.814828
\.


--
-- Data for Name: sect_tasks; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.sect_tasks (id, sect_id, type, title, description, reward_contribution, reward_stones, completed_by, reset_at) FROM stdin;
19	3	daily	焰丹炼制	为焰盟炼制基础焰丹	20	400	[]	2026-02-24 18:35:15.759
20	3	daily	阵法维护	维护焰盟护山大阵	12	250	[]	2026-02-24 18:35:15.759
21	3	daily	巡山护法	巡视焰盟山门，驱逐妖兽	15	300	[]	2026-02-24 18:35:15.759
22	3	weekly	资源运送	护送珍贵资源回焰盟	70	2500	[]	2026-02-24 18:35:15.759
23	1	daily	弟子指导	指导新入门弟子修炼	8	150	["0x82e402b05f3e936b63a874788c73e1552657c4f7"]	2026-02-25 02:25:11.881
24	1	daily	阵法维护	维护焰盟护山大阵	12	250	["0x82e402b05f3e936b63a874788c73e1552657c4f7"]	2026-02-25 02:25:11.881
25	1	daily	巡山护法	巡视焰盟山门，驱逐妖兽	15	300	["0x82e402b05f3e936b63a874788c73e1552657c4f7"]	2026-02-25 02:25:11.881
15	1	weekly	资源运送	护送珍贵资源回焰盟	70	2500	["0x82e402b05f3e936b63a874788c73e1552657c4f7"]	2026-02-23 00:50:00.261
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
2	血魔宗	以血魔之道称霸修仙界的邪道宗门，实力强横。	0xbot0000000000000000000000000000000000c3	4	9500	30	血魔宗不欢迎弱者！	2026-02-20 23:40:07.544992
3	测试	测试	0xfad7eb0814b6838b05191a07fb987957d50c4ca9	1	0	20	欢迎加入本宗门！	2026-02-24 13:35:15.239871
1	天机阁	由天机阁主青锋创立，专研剑道与丹术的神秘宗门。	0xbot0000000000000000000000000000000000a1	4	18600	35	天机阁欢迎各路焰修者！	2026-02-20 23:34:08.017582
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.settings (key, value, updated_at) FROM stdin;
gacha_equip_probs	{"epic": 0.08, "rare": 0.18, "common": 0.4, "mythic": 0.005, "uncommon": 0.3, "legendary": 0.03}	2026-02-20 12:56:16.556656-05
shop_config	{"reinforce_stone": 1000, "reinforce_stone_10": 9000}	2026-02-21 13:09:22.328051-05
gacha_config	{"r_rate": 88.5, "sr_rate": 10, "ssr_pity": 80, "ssr_rate": 1.5}	2026-02-21 13:09:23.389431-05
chain_config	{"rpcUrl": "https://rpc.roonchain.com/", "symbol": "ROON", "chainId": 1492, "decimals": 18, "chainName": "Roon Mainnet", "explorerUrl": "", "vaultContract": ""}	2026-02-24 22:27:54.473784-05
recharge_config	{"enabled": false, "minAmount": "0.01", "ratePerRoon": 10000, "confirmations": 3}	2026-02-24 22:27:54.612485-05
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
-- Name: announcements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.announcements_id_seq', 15, true);


--
-- Name: arena_battles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.arena_battles_id_seq', 34, true);


--
-- Name: arena_daily_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.arena_daily_id_seq', 108, true);


--
-- Name: arena_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.arena_notifications_id_seq', 23, true);


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

SELECT pg_catalog.setval('public.auction_history_id_seq', 7, true);


--
-- Name: auction_listings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.auction_listings_id_seq', 13, true);


--
-- Name: battle_trace_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.battle_trace_log_id_seq', 1, false);


--
-- Name: boss_damage_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.boss_damage_log_id_seq', 76, true);


--
-- Name: boss_rewards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.boss_rewards_id_seq', 4, true);


--
-- Name: bug_reports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.bug_reports_id_seq', 5, true);


--
-- Name: daily_dungeon_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.daily_dungeon_entries_id_seq', 48, true);


--
-- Name: daily_dungeons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.daily_dungeons_id_seq', 4, true);


--
-- Name: equip_slots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.equip_slots_id_seq', 217, true);


--
-- Name: equipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.equipment_id_seq', 1, true);


--
-- Name: event_claims_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.event_claims_id_seq', 5, true);


--
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.events_id_seq', 6, true);


--
-- Name: friend_gifts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.friend_gifts_id_seq', 2, true);


--
-- Name: friendships_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.friendships_id_seq', 5, true);


--
-- Name: inventory_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.inventory_items_id_seq', 126, true);


--
-- Name: leaderboard_cache_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.leaderboard_cache_id_seq', 2159, true);


--
-- Name: login_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.login_logs_id_seq', 135, true);


--
-- Name: minigame_scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.minigame_scores_id_seq', 1, false);


--
-- Name: monthly_cards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.monthly_cards_id_seq', 1, false);


--
-- Name: monthly_rankings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.monthly_rankings_id_seq', 1, false);


--
-- Name: monthly_revenue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.monthly_revenue_id_seq', 1, false);


--
-- Name: monthly_spending_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.monthly_spending_id_seq', 1, false);


--
-- Name: mounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.mounts_id_seq', 5, true);


--
-- Name: pets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.pets_id_seq', 1, false);


--
-- Name: pk_rankings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pk_rankings_id_seq', 169, true);


--
-- Name: pk_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.pk_records_id_seq', 1, false);


--
-- Name: pk_season_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.pk_season_history_id_seq', 1, false);


--
-- Name: pk_seasons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.pk_seasons_id_seq', 1, false);


--
-- Name: player_mail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.player_mail_id_seq', 39, true);


--
-- Name: player_mounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.player_mounts_id_seq', 5, true);


--
-- Name: player_titles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.player_titles_id_seq', 19, true);


--
-- Name: players_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.players_id_seq', 28, true);


--
-- Name: private_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.private_messages_id_seq', 4, true);


--
-- Name: recharge_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.recharge_log_id_seq', 7, true);


--
-- Name: sect_members_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.sect_members_id_seq', 9, true);


--
-- Name: sect_tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.sect_tasks_id_seq', 25, true);


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

SELECT pg_catalog.setval('public.sects_id_seq', 3, true);


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
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: arena_battles arena_battles_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.arena_battles
    ADD CONSTRAINT arena_battles_pkey PRIMARY KEY (id);


--
-- Name: arena_daily arena_daily_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.arena_daily
    ADD CONSTRAINT arena_daily_pkey PRIMARY KEY (id);


--
-- Name: arena_daily arena_daily_wallet_date_key; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.arena_daily
    ADD CONSTRAINT arena_daily_wallet_date_key UNIQUE (wallet, date);


--
-- Name: arena_notifications arena_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.arena_notifications
    ADD CONSTRAINT arena_notifications_pkey PRIMARY KEY (id);


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
-- Name: event_claims event_claims_event_id_wallet_key; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.event_claims
    ADD CONSTRAINT event_claims_event_id_wallet_key UNIQUE (event_id, wallet);


--
-- Name: event_claims event_claims_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.event_claims
    ADD CONSTRAINT event_claims_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
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
-- Name: leaderboard_cache leaderboard_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.leaderboard_cache
    ADD CONSTRAINT leaderboard_cache_pkey PRIMARY KEY (id);


--
-- Name: login_logs login_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.login_logs
    ADD CONSTRAINT login_logs_pkey PRIMARY KEY (id);


--
-- Name: minigame_scores minigame_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.minigame_scores
    ADD CONSTRAINT minigame_scores_pkey PRIMARY KEY (id);


--
-- Name: minigame_scores minigame_scores_wallet_month_key; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.minigame_scores
    ADD CONSTRAINT minigame_scores_wallet_month_key UNIQUE (wallet, month);


--
-- Name: monthly_cards monthly_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.monthly_cards
    ADD CONSTRAINT monthly_cards_pkey PRIMARY KEY (id);


--
-- Name: monthly_rankings monthly_rankings_month_rank_type_wallet_key; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.monthly_rankings
    ADD CONSTRAINT monthly_rankings_month_rank_type_wallet_key UNIQUE (month, rank_type, wallet);


--
-- Name: monthly_rankings monthly_rankings_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.monthly_rankings
    ADD CONSTRAINT monthly_rankings_pkey PRIMARY KEY (id);


--
-- Name: monthly_revenue monthly_revenue_month_key; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.monthly_revenue
    ADD CONSTRAINT monthly_revenue_month_key UNIQUE (month);


--
-- Name: monthly_revenue monthly_revenue_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.monthly_revenue
    ADD CONSTRAINT monthly_revenue_pkey PRIMARY KEY (id);


--
-- Name: monthly_spending monthly_spending_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.monthly_spending
    ADD CONSTRAINT monthly_spending_pkey PRIMARY KEY (id);


--
-- Name: monthly_spending monthly_spending_wallet_month_key; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.monthly_spending
    ADD CONSTRAINT monthly_spending_wallet_month_key UNIQUE (wallet, month);


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
-- Name: pk_rankings pk_rankings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pk_rankings
    ADD CONSTRAINT pk_rankings_pkey PRIMARY KEY (id);


--
-- Name: pk_rankings pk_rankings_wallet_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pk_rankings
    ADD CONSTRAINT pk_rankings_wallet_key UNIQUE (wallet);


--
-- Name: pk_records pk_records_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.pk_records
    ADD CONSTRAINT pk_records_pkey PRIMARY KEY (id);


--
-- Name: pk_season_history pk_season_history_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.pk_season_history
    ADD CONSTRAINT pk_season_history_pkey PRIMARY KEY (id);


--
-- Name: pk_season_history pk_season_history_season_num_wallet_key; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.pk_season_history
    ADD CONSTRAINT pk_season_history_season_num_wallet_key UNIQUE (season_num, wallet);


--
-- Name: pk_seasons pk_seasons_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.pk_seasons
    ADD CONSTRAINT pk_seasons_pkey PRIMARY KEY (id);


--
-- Name: pk_seasons pk_seasons_season_num_key; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.pk_seasons
    ADD CONSTRAINT pk_seasons_season_num_key UNIQUE (season_num);


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
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: players players_wallet_key; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_wallet_key UNIQUE (wallet);


--
-- Name: private_messages private_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.private_messages
    ADD CONSTRAINT private_messages_pkey PRIMARY KEY (id);


--
-- Name: recharge_log recharge_log_pkey; Type: CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.recharge_log
    ADD CONSTRAINT recharge_log_pkey PRIMARY KEY (id);


--
-- Name: recharge_log recharge_log_tx_hash_key; Type: CONSTRAINT; Schema: public; Owner: roon_user
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
-- Name: idx_mc_wallet; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_mc_wallet ON public.monthly_cards USING btree (wallet);


--
-- Name: idx_pets_owner; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_pets_owner ON public.pets USING btree (owner_id);


--
-- Name: idx_pk_created; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_pk_created ON public.pk_records USING btree (created_at DESC);


--
-- Name: idx_pk_rankings_score; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pk_rankings_score ON public.pk_rankings USING btree (rank_score DESC);


--
-- Name: idx_pk_wallet; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_pk_wallet ON public.pk_records USING btree (winner_wallet);


--
-- Name: idx_pk_wallet_a; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_pk_wallet_a ON public.pk_records USING btree (wallet_a);


--
-- Name: idx_pk_wallet_b; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_pk_wallet_b ON public.pk_records USING btree (wallet_b);


--
-- Name: idx_players_combat; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_players_combat ON public.players USING btree (combat_power DESC);


--
-- Name: idx_players_combat_power; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_players_combat_power ON public.players USING btree (combat_power DESC);


--
-- Name: idx_players_level; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_players_level ON public.players USING btree (level DESC);


--
-- Name: idx_players_total_recharge; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_players_total_recharge ON public.players USING btree (total_recharge DESC);


--
-- Name: idx_players_wallet; Type: INDEX; Schema: public; Owner: roon_user
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
-- Name: idx_recharge_tx; Type: INDEX; Schema: public; Owner: roon_user
--

CREATE INDEX idx_recharge_tx ON public.recharge_log USING btree (tx_hash);


--
-- Name: idx_recharge_wallet; Type: INDEX; Schema: public; Owner: roon_user
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
-- Name: leaderboard_cache_type_uniq; Type: INDEX; Schema: public; Owner: roon_user
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
-- Name: event_claims event_claims_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
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
-- Name: TABLE pk_rankings; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.pk_rankings TO roon_user;


--
-- Name: SEQUENCE pk_rankings_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.pk_rankings_id_seq TO roon_user;


--
-- PostgreSQL database dump complete
--

\unrestrict hiwSfvLdYGnLNSjdFtrjyOx8CX8DzLnD6FyrljPtGcrEvVlaurPCzAjbezpfiCa

