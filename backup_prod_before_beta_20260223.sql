--
-- PostgreSQL database dump
--

\restrict ZRgPnwA2gtAdOXwyVAn5NBwYjFV0du5czd04c8fANlNWJlOAs9FjfhagMgtblrG

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
    created_at timestamp with time zone DEFAULT now()
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
    banned boolean DEFAULT false
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
-- Name: boss_damage_log id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.boss_damage_log ALTER COLUMN id SET DEFAULT nextval('public.boss_damage_log_id_seq'::regclass);


--
-- Name: boss_rewards id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.boss_rewards ALTER COLUMN id SET DEFAULT nextval('public.boss_rewards_id_seq'::regclass);


--
-- Name: daily_dungeon_entries id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.daily_dungeon_entries ALTER COLUMN id SET DEFAULT nextval('public.daily_dungeon_entries_id_seq'::regclass);


--
-- Name: daily_dungeons id; Type: DEFAULT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.daily_dungeons ALTER COLUMN id SET DEFAULT nextval('public.daily_dungeons_id_seq'::regclass);


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
\.


--
-- Data for Name: auction_listings; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.auction_listings (id, seller_wallet, seller_name, item_data, item_name, item_type, item_quality, starting_price, buyout_price, current_bid, current_bidder, bid_count, duration_hours, status, expires_at, created_at) FROM stdin;
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
-- Data for Name: daily_dungeon_entries; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.daily_dungeon_entries (id, dungeon_id, wallet, player_name, result, rewards_earned, entry_date, created_at) FROM stdin;
\.


--
-- Data for Name: daily_dungeons; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.daily_dungeons (id, name, description, difficulty, min_level, max_entries, enemy_config, rewards_config, created_at) FROM stdin;
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
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.events (id, name, type, config, starts_at, ends_at, active, created_at, description, rewards) FROM stdin;
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
-- Data for Name: leaderboard_cache; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.leaderboard_cache (id, type, data, updated_at) FROM stdin;
297	level	[]	2026-02-23 07:25:19.540708
298	combat_power	[]	2026-02-23 07:25:19.543882
299	recharge	[]	2026-02-23 07:25:19.545483
\.


--
-- Data for Name: login_logs; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.login_logs (id, wallet, ip, user_agent, created_at) FROM stdin;
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
\.


--
-- Data for Name: pets; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.pets (id, owner_id, name, description, rarity, level, star, combat_attributes, is_active, created_at) FROM stdin;
\.


--
-- Data for Name: pk_records; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pk_records (id, wallet_a, wallet_b, name_a, name_b, winner, winner_wallet, rounds_data, reward, created_at) FROM stdin;
\.


--
-- Data for Name: player_mail; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.player_mail (id, to_wallet, from_type, from_name, title, content, rewards, is_read, is_claimed, expires_at, created_at, from_wallet) FROM stdin;
\.


--
-- Data for Name: player_mounts; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.player_mounts (id, wallet, mount_id, level, exp, is_active, obtained_at) FROM stdin;
\.


--
-- Data for Name: player_titles; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.player_titles (id, wallet, title_id, is_active, obtained_at) FROM stdin;
\.


--
-- Data for Name: players; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.players (id, wallet, name, game_data, vip_level, total_recharge, spirit_stones, level, realm, combat_power, first_recharge, daily_sign_date, daily_sign_streak, created_at, updated_at, banned) FROM stdin;
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
\.


--
-- Data for Name: world_bosses; Type: TABLE DATA; Schema: public; Owner: roon_user
--

COPY public.world_bosses (id, name, level, max_hp, current_hp, attack, defense, description, rewards_config, status, spawn_time, death_time, created_at) FROM stdin;
\.


--
-- Name: admin_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.admin_logs_id_seq', 9, true);


--
-- Name: announcements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.announcements_id_seq', 6, true);


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

SELECT pg_catalog.setval('public.auction_history_id_seq', 3, true);


--
-- Name: auction_listings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.auction_listings_id_seq', 8, true);


--
-- Name: boss_damage_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.boss_damage_log_id_seq', 39, true);


--
-- Name: boss_rewards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.boss_rewards_id_seq', 1, false);


--
-- Name: daily_dungeon_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.daily_dungeon_entries_id_seq', 31, true);


--
-- Name: daily_dungeons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.daily_dungeons_id_seq', 4, true);


--
-- Name: equipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.equipment_id_seq', 1, true);


--
-- Name: event_claims_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.event_claims_id_seq', 2, true);


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
-- Name: leaderboard_cache_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.leaderboard_cache_id_seq', 1052, true);


--
-- Name: login_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.login_logs_id_seq', 1, false);


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
-- Name: pk_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pk_records_id_seq', 1, false);


--
-- Name: player_mail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roon_user
--

SELECT pg_catalog.setval('public.player_mail_id_seq', 28, true);


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

SELECT pg_catalog.setval('public.players_id_seq', 13, true);


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
-- Name: event_claims event_claims_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_claims
    ADD CONSTRAINT event_claims_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id);


--
-- Name: player_mounts player_mounts_mount_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: roon_user
--

ALTER TABLE ONLY public.player_mounts
    ADD CONSTRAINT player_mounts_mount_id_fkey FOREIGN KEY (mount_id) REFERENCES public.mounts(id);


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

\unrestrict ZRgPnwA2gtAdOXwyVAn5NBwYjFV0du5czd04c8fANlNWJlOAs9FjfhagMgtblrG

