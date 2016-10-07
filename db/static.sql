--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.0
-- Dumped by pg_dump version 9.5.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

DROP INDEX public.index_offences_on_offence_class_id;
DROP INDEX public.index_offence_classes_on_description;
DROP INDEX public.index_offence_classes_on_class_letter;
DROP INDEX public.index_fee_types_on_description;
DROP INDEX public.index_fee_types_on_code;
DROP INDEX public.index_expense_types_on_name;
DROP INDEX public.index_disbursement_types_on_name;
DROP INDEX public.index_courts_on_name;
DROP INDEX public.index_courts_on_court_type;
DROP INDEX public.index_courts_on_code;
ALTER TABLE ONLY public.offences DROP CONSTRAINT offences_pkey;
ALTER TABLE ONLY public.offence_classes DROP CONSTRAINT offence_classes_pkey;
ALTER TABLE ONLY public.fee_types DROP CONSTRAINT fee_types_pkey;
ALTER TABLE ONLY public.expense_types DROP CONSTRAINT expense_types_pkey;
ALTER TABLE ONLY public.disbursement_types DROP CONSTRAINT disbursement_types_pkey;
ALTER TABLE ONLY public.courts DROP CONSTRAINT courts_pkey;
ALTER TABLE ONLY public.case_types DROP CONSTRAINT case_types_pkey;
ALTER TABLE public.offences ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.offence_classes ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.fee_types ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.expense_types ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.disbursement_types ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.courts ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.case_types ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE public.offences_id_seq;
DROP TABLE public.offences;
DROP SEQUENCE public.offence_classes_id_seq;
DROP TABLE public.offence_classes;
DROP SEQUENCE public.fee_types_id_seq;
DROP TABLE public.fee_types;
DROP SEQUENCE public.expense_types_id_seq;
DROP TABLE public.expense_types;
DROP SEQUENCE public.disbursement_types_id_seq;
DROP TABLE public.disbursement_types;
DROP SEQUENCE public.courts_id_seq;
DROP TABLE public.courts;
DROP SEQUENCE public.case_types_id_seq;
DROP TABLE public.case_types;
SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: case_types; Type: TABLE; Schema: public; Owner: stephenrichards
--

CREATE TABLE case_types (
    id integer NOT NULL,
    name character varying,
    is_fixed_fee boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    requires_cracked_dates boolean,
    requires_trial_dates boolean,
    allow_pcmh_fee_type boolean DEFAULT false,
    requires_maat_reference boolean DEFAULT false,
    requires_retrial_dates boolean DEFAULT false,
    roles character varying,
    fee_type_code character varying
);


ALTER TABLE case_types OWNER TO stephenrichards;

--
-- Name: case_types_id_seq; Type: SEQUENCE; Schema: public; Owner: stephenrichards
--

CREATE SEQUENCE case_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE case_types_id_seq OWNER TO stephenrichards;

--
-- Name: case_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: stephenrichards
--

ALTER SEQUENCE case_types_id_seq OWNED BY case_types.id;


--
-- Name: courts; Type: TABLE; Schema: public; Owner: stephenrichards
--

CREATE TABLE courts (
    id integer NOT NULL,
    code character varying,
    name character varying,
    court_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE courts OWNER TO stephenrichards;

--
-- Name: courts_id_seq; Type: SEQUENCE; Schema: public; Owner: stephenrichards
--

CREATE SEQUENCE courts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE courts_id_seq OWNER TO stephenrichards;

--
-- Name: courts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: stephenrichards
--

ALTER SEQUENCE courts_id_seq OWNED BY courts.id;


--
-- Name: disbursement_types; Type: TABLE; Schema: public; Owner: stephenrichards
--

CREATE TABLE disbursement_types (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


ALTER TABLE disbursement_types OWNER TO stephenrichards;

--
-- Name: disbursement_types_id_seq; Type: SEQUENCE; Schema: public; Owner: stephenrichards
--

CREATE SEQUENCE disbursement_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE disbursement_types_id_seq OWNER TO stephenrichards;

--
-- Name: disbursement_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: stephenrichards
--

ALTER SEQUENCE disbursement_types_id_seq OWNED BY disbursement_types.id;


--
-- Name: expense_types; Type: TABLE; Schema: public; Owner: stephenrichards
--

CREATE TABLE expense_types (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    roles character varying,
    reason_set character varying
);


ALTER TABLE expense_types OWNER TO stephenrichards;

--
-- Name: expense_types_id_seq; Type: SEQUENCE; Schema: public; Owner: stephenrichards
--

CREATE SEQUENCE expense_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE expense_types_id_seq OWNER TO stephenrichards;

--
-- Name: expense_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: stephenrichards
--

ALTER SEQUENCE expense_types_id_seq OWNED BY expense_types.id;


--
-- Name: fee_types; Type: TABLE; Schema: public; Owner: stephenrichards
--

CREATE TABLE fee_types (
    id integer NOT NULL,
    description character varying,
    code character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    max_amount numeric,
    calculated boolean DEFAULT true,
    type character varying,
    roles character varying,
    parent_id integer,
    quantity_is_decimal boolean DEFAULT false
);


ALTER TABLE fee_types OWNER TO stephenrichards;

--
-- Name: fee_types_id_seq; Type: SEQUENCE; Schema: public; Owner: stephenrichards
--

CREATE SEQUENCE fee_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE fee_types_id_seq OWNER TO stephenrichards;

--
-- Name: fee_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: stephenrichards
--

ALTER SEQUENCE fee_types_id_seq OWNED BY fee_types.id;


--
-- Name: offence_classes; Type: TABLE; Schema: public; Owner: stephenrichards
--

CREATE TABLE offence_classes (
    id integer NOT NULL,
    class_letter character varying,
    description character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE offence_classes OWNER TO stephenrichards;

--
-- Name: offence_classes_id_seq; Type: SEQUENCE; Schema: public; Owner: stephenrichards
--

CREATE SEQUENCE offence_classes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE offence_classes_id_seq OWNER TO stephenrichards;

--
-- Name: offence_classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: stephenrichards
--

ALTER SEQUENCE offence_classes_id_seq OWNED BY offence_classes.id;


--
-- Name: offences; Type: TABLE; Schema: public; Owner: stephenrichards
--

CREATE TABLE offences (
    id integer NOT NULL,
    description character varying,
    offence_class_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE offences OWNER TO stephenrichards;

--
-- Name: offences_id_seq; Type: SEQUENCE; Schema: public; Owner: stephenrichards
--

CREATE SEQUENCE offences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE offences_id_seq OWNER TO stephenrichards;

--
-- Name: offences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: stephenrichards
--

ALTER SEQUENCE offences_id_seq OWNED BY offences.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: stephenrichards
--

ALTER TABLE ONLY case_types ALTER COLUMN id SET DEFAULT nextval('case_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: stephenrichards
--

ALTER TABLE ONLY courts ALTER COLUMN id SET DEFAULT nextval('courts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: stephenrichards
--

ALTER TABLE ONLY disbursement_types ALTER COLUMN id SET DEFAULT nextval('disbursement_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: stephenrichards
--

ALTER TABLE ONLY expense_types ALTER COLUMN id SET DEFAULT nextval('expense_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: stephenrichards
--

ALTER TABLE ONLY fee_types ALTER COLUMN id SET DEFAULT nextval('fee_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: stephenrichards
--

ALTER TABLE ONLY offence_classes ALTER COLUMN id SET DEFAULT nextval('offence_classes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: stephenrichards
--

ALTER TABLE ONLY offences ALTER COLUMN id SET DEFAULT nextval('offences_id_seq'::regclass);


--
-- Data for Name: case_types; Type: TABLE DATA; Schema: public; Owner: stephenrichards
--

COPY case_types (id, name, is_fixed_fee, created_at, updated_at, requires_cracked_dates, requires_trial_dates, allow_pcmh_fee_type, requires_maat_reference, requires_retrial_dates, roles, fee_type_code) FROM stdin;
6	Cracked Trial	f	2015-11-05 17:08:47.235611	2016-04-11 18:04:55.666598	t	f	t	t	f	---\n- agfs\n- lgfs\n	GCRAK
7	Cracked before retrial	f	2015-11-05 17:08:47.244617	2016-04-11 18:04:55.674958	t	f	t	t	f	---\n- agfs\n- lgfs\n	GCBR
8	Discontinuance	f	2015-11-05 17:08:47.250605	2016-04-11 18:04:55.681784	f	f	t	t	f	---\n- agfs\n- lgfs\n	GDIS
10	Guilty plea	f	2015-11-05 17:08:47.261211	2016-04-11 18:04:55.693964	f	f	t	t	f	---\n- agfs\n- lgfs\n	GGLTY
1	Appeal against conviction	t	2015-11-05 17:08:47.199514	2016-04-13 09:00:27.652868	f	f	f	t	f	---\n- agfs\n- lgfs\n	ACV
2	Appeal against sentence	t	2015-11-05 17:08:47.210504	2016-04-13 09:00:27.785237	f	f	f	t	f	---\n- agfs\n- lgfs\n	ASE
3	Breach of Crown Court order	t	2015-11-05 17:08:47.219069	2016-04-13 09:00:27.899525	f	f	f	f	f	---\n- agfs\n- lgfs\n	CBR
4	Committal for Sentence	t	2015-11-05 17:08:47.224707	2016-04-13 09:00:27.924834	f	f	f	t	f	---\n- agfs\n- lgfs\n	CSE
5	Contempt	t	2015-11-05 17:08:47.23016	2016-04-13 09:00:27.963218	f	f	f	t	f	---\n- agfs\n- lgfs\n	ZCON
9	Elected cases not proceeded	t	2015-11-05 17:08:47.255779	2016-04-13 09:00:27.983597	f	f	f	t	f	---\n- agfs\n- lgfs\n	ENP
13	Hearing subsequent to sentence	t	2016-03-07 14:14:11.272429	2016-04-13 09:00:28.003402	f	f	f	t	f	---\n- lgfs\n	XH2S
11	Retrial	f	2015-11-05 17:08:47.266609	2016-04-15 16:14:22.944989	f	t	t	t	t	---\n- agfs\n- lgfs\n- interim\n	GRTR
12	Trial	f	2015-11-05 17:08:47.271658	2016-04-15 16:14:22.954153	f	t	t	t	f	---\n- agfs\n- lgfs\n- interim\n	GTRL
\.


--
-- Name: case_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: stephenrichards
--

SELECT pg_catalog.setval('case_types_id_seq', 18, true);


--
-- Data for Name: courts; Type: TABLE DATA; Schema: public; Owner: stephenrichards
--

COPY courts (id, code, name, court_type, created_at, updated_at) FROM stdin;
1	401	Aylesbury Crown	crown	2015-11-05 17:08:58.325451	2015-11-05 17:08:58.325451
2	461	Basildon Crown	crown	2015-11-05 17:08:58.334104	2015-11-05 17:08:58.334104
3	404	Birmingham Crown	crown	2015-11-05 17:08:58.343619	2015-11-05 17:08:58.343619
4	428	Blackfriars Crown	crown	2015-11-05 17:08:58.351145	2015-11-05 17:08:58.351145
5	470	Bolton Crown	crown	2015-11-05 17:08:58.357962	2015-11-05 17:08:58.357962
6	406	Bournemouth Crown	crown	2015-11-05 17:08:58.365284	2015-11-05 17:08:58.365284
7	402	Bradford Crown	crown	2015-11-05 17:08:58.372473	2015-11-05 17:08:58.372473
8	408	Bristol Crown	crown	2015-11-05 17:08:58.379317	2015-11-05 17:08:58.379317
9	409	Burnley Crown	crown	2015-11-05 17:08:58.38619	2015-11-05 17:08:58.38619
10	410	Cambridge Crown	crown	2015-11-05 17:08:58.393143	2015-11-05 17:08:58.393143
11	479	Canterbury Crown	crown	2015-11-05 17:08:58.39991	2015-11-05 17:08:58.39991
12	411	Cardiff Crown	crown	2015-11-05 17:08:58.406873	2015-11-05 17:08:58.406873
13	412	Carlisle Crown	crown	2015-11-05 17:08:58.413741	2015-11-05 17:08:58.413741
14	413	Central Criminal Court	crown	2015-11-05 17:08:58.42062	2015-11-05 17:08:58.42062
15	414	Chelmsford Crown	crown	2015-11-05 17:08:58.427502	2015-11-05 17:08:58.427502
16	415	Chester Crown	crown	2015-11-05 17:08:58.438436	2015-11-05 17:08:58.438436
17	416	Chichester Crown	crown	2015-11-05 17:08:58.446535	2015-11-05 17:08:58.446535
18	417	Coventry Crown	crown	2015-11-05 17:08:58.453322	2015-11-05 17:08:58.453322
19	418	Croydon Crown	crown	2015-11-05 17:08:58.464903	2015-11-05 17:08:58.464903
20	419	Derby Crown	crown	2015-11-05 17:08:58.477206	2015-11-05 17:08:58.477206
21	420	Doncaster Crown	crown	2015-11-05 17:08:58.484357	2015-11-05 17:08:58.484357
22	422	Durham Crown	crown	2015-11-05 17:08:58.491233	2015-11-05 17:08:58.491233
23	423	Exeter Crown	crown	2015-11-05 17:08:58.498042	2015-11-05 17:08:58.498042
24	424	Gloucester Crown	crown	2015-11-05 17:08:58.504933	2015-11-05 17:08:58.504933
25	425	Grimsby Crown	crown	2015-11-05 17:08:58.511864	2015-11-05 17:08:58.511864
26	474	Guildford Crown	crown	2015-11-05 17:08:58.51866	2015-11-05 17:08:58.51866
27	468	Harrow Crown	crown	2015-11-05 17:08:58.525484	2015-11-05 17:08:58.525484
28	403	Hull Crown	crown	2015-11-05 17:08:58.532306	2015-11-05 17:08:58.532306
29	440	Inner London Crown	crown	2015-11-05 17:08:58.539214	2015-11-05 17:08:58.539214
30	426	Ipswich Crown	crown	2015-11-05 17:08:58.54696	2015-11-05 17:08:58.54696
31	475	Isleworth Crown	crown	2015-11-05 17:08:58.553975	2015-11-05 17:08:58.553975
32	427	Kingston Upon Thames Crown	crown	2015-11-05 17:08:58.561611	2015-11-05 17:08:58.561611
33	429	Leeds Crown	crown	2015-11-05 17:08:58.568658	2015-11-05 17:08:58.568658
34	430	Leicester Crown	crown	2015-11-05 17:08:58.575427	2015-11-05 17:08:58.575427
35	431	Lewes Crown	crown	2015-11-05 17:08:58.582482	2015-11-05 17:08:58.582482
36	432	Lincoln Crown	crown	2015-11-05 17:08:58.589428	2015-11-05 17:08:58.589428
37	433	Liverpool Crown	crown	2015-11-05 17:08:58.596454	2015-11-05 17:08:58.596454
38	476	Luton Crown	crown	2015-11-05 17:08:58.603284	2015-11-05 17:08:58.603284
39	434	Maidstone Crown	crown	2015-11-05 17:08:58.610526	2015-11-05 17:08:58.610526
40	435	Manchester (Crown Sq)	crown	2015-11-05 17:08:58.626881	2015-11-05 17:08:58.626881
41	436	Manchester (Minshull St)	crown	2015-11-05 17:08:58.634163	2015-11-05 17:08:58.634163
42	437	Merthyr Tydfil Crown	crown	2015-11-05 17:08:58.641164	2015-11-05 17:08:58.641164
43	464	Middx Guildhall Crown	crown	2015-11-05 17:08:58.648919	2015-11-05 17:08:58.648919
44	438	Mold Crown	crown	2015-11-05 17:08:58.656825	2015-11-05 17:08:58.656825
45	439	Newcastle Crown	crown	2015-11-05 17:08:58.663693	2015-11-05 17:08:58.663693
46	478	Newport (IOW) Crown	crown	2015-11-05 17:08:58.670794	2015-11-05 17:08:58.670794
47	441	Newport Crown	crown	2015-11-05 17:08:58.677755	2015-11-05 17:08:58.677755
48	442	Northampton Crown	crown	2015-11-05 17:08:58.684533	2015-11-05 17:08:58.684533
49	443	Norwich Crown	crown	2015-11-05 17:08:58.691748	2015-11-05 17:08:58.691748
50	444	Nottingham Crown	crown	2015-11-05 17:08:58.698722	2015-11-05 17:08:58.698722
51	445	Oxford Crown	crown	2015-11-05 17:08:58.705442	2015-11-05 17:08:58.705442
52	473	Peterborough Crown	crown	2015-11-05 17:08:58.712197	2015-11-05 17:08:58.712197
53	446	Plymouth Crown	crown	2015-11-05 17:08:58.718861	2015-11-05 17:08:58.718861
54	447	Portsmouth Crown	crown	2015-11-05 17:08:58.725814	2015-11-05 17:08:58.725814
55	448	Preston Crown	crown	2015-11-05 17:08:58.732472	2015-11-05 17:08:58.732472
56	449	Reading Crown	crown	2015-11-05 17:08:58.739178	2015-11-05 17:08:58.739178
57	480	Salisbury Crown	crown	2015-11-05 17:08:58.745889	2015-11-05 17:08:58.745889
58	451	Sheffield Crown	crown	2015-11-05 17:08:58.753564	2015-11-05 17:08:58.753564
59	452	Shrewsbury Crown	crown	2015-11-05 17:08:58.760491	2015-11-05 17:08:58.760491
60	453	Snaresbrook Crown	crown	2015-11-05 17:08:58.767362	2015-11-05 17:08:58.767362
61	454	Southampton Crown	crown	2015-11-05 17:08:58.774262	2015-11-05 17:08:58.774262
62	471	Southwark Crown	crown	2015-11-05 17:08:58.781267	2015-11-05 17:08:58.781267
63	450	St Albans Crown	crown	2015-11-05 17:08:58.788172	2015-11-05 17:08:58.788172
64	455	Stafford Crown	crown	2015-11-05 17:08:58.795058	2015-11-05 17:08:58.795058
65	456	Stoke on Trent Crown	crown	2015-11-05 17:08:58.802197	2015-11-05 17:08:58.802197
66	457	Swansea Crown	crown	2015-11-05 17:08:58.809083	2015-11-05 17:08:58.809083
67	458	Swindon Crown	crown	2015-11-05 17:08:58.815912	2015-11-05 17:08:58.815912
68	459	Taunton Crown	crown	2015-11-05 17:08:58.82268	2015-11-05 17:08:58.82268
70	477	Truro Crown	crown	2015-11-05 17:08:58.836661	2015-11-05 17:08:58.836661
71	462	Warrington Crown	crown	2015-11-05 17:08:58.843749	2015-11-05 17:08:58.843749
72	463	Warwick Crown	crown	2015-11-05 17:08:58.852016	2015-11-05 17:08:58.852016
73	407	Weymouth and Dorcester Crown	crown	2015-11-05 17:08:58.858979	2015-11-05 17:08:58.858979
74	465	Winchester Crown	crown	2015-11-05 17:08:58.866048	2015-11-05 17:08:58.866048
75	421	Wolverhampton Crown	crown	2015-11-05 17:08:58.873088	2015-11-05 17:08:58.873088
76	469	Wood Green Crown	crown	2015-11-05 17:08:58.88056	2015-11-05 17:08:58.88056
77	472	Woolwich Crown	crown	2015-11-05 17:08:58.887601	2015-11-05 17:08:58.887601
78	466	Worcester Crown	crown	2015-11-05 17:08:58.894692	2015-11-05 17:08:58.894692
79	467	York Crown	crown	2015-11-05 17:08:58.901684	2015-11-05 17:08:58.901684
69	460	Teesside Crown	crown	2015-11-05 17:08:58.829451	2015-11-05 17:08:58.829451
\.


--
-- Name: courts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: stephenrichards
--

SELECT pg_catalog.setval('courts_id_seq', 79, true);


--
-- Data for Name: disbursement_types; Type: TABLE DATA; Schema: public; Owner: stephenrichards
--

COPY disbursement_types (id, name, created_at, updated_at, deleted_at) FROM stdin;
1	Accident reconstruction report	2016-03-16 09:30:02.646119	2016-03-16 09:30:02.646119	\N
2	Accounts	2016-03-16 09:30:02.651804	2016-03-16 09:30:02.651804	\N
3	Computer experts	2016-03-16 09:30:02.656331	2016-03-16 09:30:02.656331	\N
4	Consultant medical reports	2016-03-16 09:30:02.660853	2016-03-16 09:30:02.660853	\N
5	Costs judge application fee	2016-03-16 09:30:02.665244	2016-03-16 09:30:02.665244	\N
6	Costs judge preparation award	2016-03-16 09:30:02.669719	2016-03-16 09:30:02.669719	\N
7	DNA testing	2016-03-16 09:30:02.673857	2016-03-16 09:30:02.673857	\N
8	Engineer	2016-03-16 09:30:02.677682	2016-03-16 09:30:02.677682	\N
9	Enquiry agents	2016-03-16 09:30:02.681346	2016-03-16 09:30:02.681346	\N
10	Facial mapping expert	2016-03-16 09:30:02.688145	2016-03-16 09:30:02.688145	\N
11	Financial expert	2016-03-16 09:30:02.692315	2016-03-16 09:30:02.692315	\N
12	Fingerprint expert	2016-03-16 09:30:02.696363	2016-03-16 09:30:02.696363	\N
13	Fire assessor/explosives expert	2016-03-16 09:30:02.69994	2016-03-16 09:30:02.69994	\N
14	Forensic scientists	2016-03-16 09:30:02.703962	2016-03-16 09:30:02.703962	\N
15	Handwriting expert	2016-03-16 09:30:02.708454	2016-03-16 09:30:02.708454	\N
16	Interpreter	2016-03-16 09:30:02.71283	2016-03-16 09:30:02.71283	\N
17	Lip readers	2016-03-16 09:30:02.716825	2016-03-16 09:30:02.716825	\N
18	Medical expert	2016-03-16 09:30:02.737727	2016-03-16 09:30:02.737727	\N
19	Memorandum of conviction fee	2016-03-16 09:30:02.741218	2016-03-16 09:30:02.741218	\N
20	Meteorologist	2016-03-16 09:30:02.74449	2016-03-16 09:30:02.74449	\N
21	Other	2016-03-16 09:30:02.747826	2016-03-16 09:30:02.747826	\N
22	Overnight expenses	2016-03-16 09:30:02.751148	2016-03-16 09:30:02.751148	\N
23	Pathologist	2016-03-16 09:30:02.754407	2016-03-16 09:30:02.754407	\N
24	Photocopying	2016-03-16 09:30:02.757795	2016-03-16 09:30:02.757795	\N
25	Psychiatric reports	2016-03-16 09:30:02.761206	2016-03-16 09:30:02.761206	\N
26	Psychological report	2016-03-16 09:30:02.764477	2016-03-16 09:30:02.764477	\N
27	Surveyor/architect	2016-03-16 09:30:02.767773	2016-03-16 09:30:02.767773	\N
28	Transcripts	2016-03-16 09:30:02.771108	2016-03-16 09:30:02.771108	\N
29	Translator	2016-03-16 09:30:02.774428	2016-03-16 09:30:02.774428	\N
31	Vet report	2016-03-16 09:30:02.781076	2016-03-16 09:30:02.781076	\N
32	Voice recognition	2016-03-16 09:30:02.78526	2016-03-16 09:30:02.78526	\N
30	Travel costs	2016-03-16 09:30:02.777728	2016-09-02 15:29:01.331336	2016-09-02 15:29:01.322485
\.


--
-- Name: disbursement_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: stephenrichards
--

SELECT pg_catalog.setval('disbursement_types_id_seq', 32, true);


--
-- Data for Name: expense_types; Type: TABLE DATA; Schema: public; Owner: stephenrichards
--

COPY expense_types (id, name, created_at, updated_at, roles, reason_set) FROM stdin;
11	Car travel	2016-04-11 18:04:06.926717	2016-04-11 18:04:06.926717	---\n- agfs\n- lgfs\n	A
12	Parking	2016-04-11 18:04:06.939741	2016-04-11 18:04:06.939741	---\n- agfs\n- lgfs\n	A
13	Hotel accommodation	2016-04-11 18:04:06.948919	2016-04-11 18:04:06.948919	---\n- agfs\n- lgfs\n	A
14	Train/public transport	2016-04-11 18:04:06.957808	2016-04-11 18:04:06.957808	---\n- agfs\n- lgfs\n	A
15	Travel time	2016-04-11 18:04:06.966307	2016-04-11 18:04:06.966307	---\n- agfs\n	B
16	Road or tunnel tolls	2016-07-21 15:31:26.604649	2016-07-21 15:31:26.604649	---\n- agfs\n- lgfs\n	A
17	Cab fares	2016-07-21 15:31:26.615092	2016-07-21 15:31:26.615092	---\n- agfs\n- lgfs\n	A
18	Subsistence	2016-07-21 15:31:26.623053	2016-07-21 15:31:26.623053	---\n- agfs\n- lgfs\n	A
\.


--
-- Name: expense_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: stephenrichards
--

SELECT pg_catalog.setval('expense_types_id_seq', 18, true);


--
-- Data for Name: fee_types; Type: TABLE DATA; Schema: public; Owner: stephenrichards
--

COPY fee_types (id, description, code, created_at, updated_at, max_amount, calculated, type, roles, parent_id, quantity_is_decimal) FROM stdin;
2	Daily attendance fee (3 to 40)	DAF	2015-11-05 17:08:50.454499	2016-03-02 11:22:59.013954	999.0	t	Fee::BasicFeeType	---\n- agfs\n	\N	f
3	Daily attendance fee (41 to 50)	DAH	2015-11-05 17:08:50.46179	2016-03-02 11:22:59.020472	9999.0	t	Fee::BasicFeeType	---\n- agfs\n	\N	f
4	Daily attendance fee (51+)	DAJ	2015-11-05 17:08:50.468666	2016-03-02 11:22:59.027251	999.0	t	Fee::BasicFeeType	---\n- agfs\n	\N	f
5	Standard appearance fee	SAF	2015-11-05 17:08:50.477797	2016-03-02 11:22:59.033866	999.0	t	Fee::BasicFeeType	---\n- agfs\n	\N	f
6	Plea and case management hearing	PCM	2015-11-05 17:08:50.48446	2016-03-02 11:22:59.040247	999.0	t	Fee::BasicFeeType	---\n- agfs\n	\N	f
8	Number of defendants uplift	NDR	2015-11-05 17:08:50.499198	2016-03-02 11:22:59.053453	\N	t	Fee::BasicFeeType	---\n- agfs\n	\N	f
9	Number of cases uplift	NOC	2015-11-05 17:08:50.50612	2016-03-02 11:22:59.059755	\N	t	Fee::BasicFeeType	---\n- agfs\n	\N	f
13	Appeals to the crown court against conviction uplift	ACU	2015-11-05 17:08:50.53303	2016-03-02 11:22:59.073116	\N	t	Fee::FixedFeeType	---\n- agfs\n	\N	f
15	Appeals to the crown court against sentence uplift	ASU	2015-11-05 17:08:50.545992	2016-03-02 11:22:59.08594	\N	t	Fee::FixedFeeType	---\n- agfs\n	\N	f
17	Breach of a crown court order uplift	CBU	2015-11-05 17:08:50.559367	2016-03-02 11:22:59.098392	\N	t	Fee::FixedFeeType	---\n- agfs\n	\N	f
21	Committal for sentence hearings uplift	CSU	2015-11-05 17:08:50.585474	2016-03-02 11:22:59.111525	\N	t	Fee::FixedFeeType	---\n- agfs\n	\N	f
23	Cracked case discontinued uplift	CDU	2015-11-05 17:08:50.606017	2016-03-02 11:22:59.117869	\N	t	Fee::FixedFeeType	---\n- agfs\n	\N	f
28	Standard appearance fee	SAF	2015-11-05 17:08:50.641206	2016-03-02 11:22:59.136387	\N	t	Fee::FixedFeeType	---\n- agfs\n	\N	f
29	Abuse of process hearings (half day)	APH	2015-11-05 17:08:50.648618	2016-03-02 11:22:59.143826	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
30	Abuse of process hearings (whole day)	APW	2015-11-05 17:08:50.655636	2016-03-02 11:22:59.150177	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
31	Abuse of process hearings (half day uplift)	AHU	2015-11-05 17:08:50.66233	2016-03-02 11:22:59.156611	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
32	Abuse of process hearings (whole day uplift)	AWU	2015-11-05 17:08:50.668767	2016-03-02 11:22:59.163033	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
38	Confiscation hearings (half day)	DTH	2015-11-05 17:08:50.710717	2016-03-02 11:22:59.169552	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
39	Confiscation hearings (whole day)	DTW	2015-11-05 17:08:50.717469	2016-03-02 11:22:59.17672	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
40	Confiscation hearings (half day uplift)	DHU	2015-11-05 17:08:50.725006	2016-03-02 11:22:59.182928	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
41	Confiscation hearings (whole day uplift)	DWU	2015-11-05 17:08:50.731916	2016-03-02 11:22:59.189807	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
42	Deferred sentence hearings	DSE	2015-11-05 17:08:50.738632	2016-03-02 11:22:59.196561	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
43	Deferred sentence hearings uplift	DSU	2015-11-05 17:08:50.745506	2016-03-02 11:22:59.202534	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
44	Hearings relating to admissibility of evidence (half day)	AEH	2015-11-05 17:08:50.752113	2016-03-02 11:22:59.210293	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
46	Hearings relating to admissibility of evidence (half day uplift)	EHU	2015-11-05 17:08:50.774428	2016-03-02 11:22:59.216487	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
47	Hearings relating to admissibility of evidence (whole day uplift)	EWU	2015-11-05 17:08:50.780985	2016-03-02 11:22:59.222505	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
48	Hearings relating to disclosure (half day)	HDH	2015-11-05 17:08:50.79681	2016-03-02 11:22:59.228658	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
49	Hearings relating to disclosure (whole day)	HDW	2015-11-05 17:08:50.803381	2016-03-02 11:22:59.235139	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
50	Hearings relating to disclosure (half day uplift)	HHU	2015-11-05 17:08:50.810209	2016-03-02 11:22:59.242186	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
51	Hearings relating to disclosure (whole day uplift)	HWU	2015-11-05 17:08:50.817105	2016-03-02 11:22:59.248219	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
52	Noting brief fee	NBR	2015-11-05 17:08:50.826925	2016-03-02 11:22:59.270054	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
53	Paper plea & case management	PPC	2015-11-05 17:08:50.836919	2016-03-02 11:22:59.275536	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
54	Paper plea & case management uplift	PCU	2015-11-05 17:08:50.843645	2016-03-02 11:22:59.280816	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
55	Proceeds of crime hearings (half day)	PCH	2015-11-05 17:08:50.849995	2016-03-02 11:22:59.286062	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
56	Proceeds of crime hearings (whole day)	PCW	2015-11-05 17:08:50.856887	2016-03-02 11:22:59.291337	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
57	Proceeds of crime hearings (half day uplift)	CHU	2015-11-05 17:08:50.863538	2016-03-02 11:22:59.296915	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
58	Proceeds of crime hearings (whole day uplift)	CHW	2015-11-05 17:08:50.870007	2016-03-02 11:22:59.302447	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
59	Public interest immunity hearings (half day)	PAH	2015-11-05 17:08:50.876828	2016-03-02 11:22:59.307803	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
60	Public interest immunity hearings (whole day)	PAW	2015-11-05 17:08:50.883378	2016-03-02 11:22:59.313817	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
61	Public interest immunity hearings (half day uplift)	PHU	2015-11-05 17:08:50.89044	2016-03-02 11:22:59.319033	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
62	Public interest immunity hearings (whole day uplift)	PWU	2015-11-05 17:08:50.897163	2016-03-02 11:22:59.324258	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
12	Appeals to the crown court against conviction	ACV	2015-11-05 17:08:50.52629	2016-04-11 18:04:55.059837	\N	t	Fee::FixedFeeType	---\n- agfs\n- lgfs\n	\N	f
14	Appeals to the crown court against sentence	ASE	2015-11-05 17:08:50.53948	2016-04-11 18:04:55.077043	\N	t	Fee::FixedFeeType	---\n- agfs\n- lgfs\n	\N	f
16	Breach of a crown court order	CBR	2015-11-05 17:08:50.55261	2016-04-11 18:04:55.092415	\N	t	Fee::FixedFeeType	---\n- agfs\n- lgfs\n	\N	f
20	Committal for sentence hearings	CSE	2015-11-05 17:08:50.579051	2016-04-11 18:04:55.119927	\N	t	Fee::FixedFeeType	---\n- agfs\n- lgfs\n	\N	f
26	Number of cases uplift	NOC	2015-11-05 17:08:50.628228	2016-04-11 18:04:55.166927	\N	t	Fee::FixedFeeType	---\n- agfs\n- lgfs\n	\N	f
27	Number of defendants uplift	NDR	2015-11-05 17:08:50.634833	2016-04-11 18:04:55.175733	\N	t	Fee::FixedFeeType	---\n- agfs\n- lgfs\n	\N	f
83	Hearing subsequent to sentence	XH2S	2016-04-11 18:04:55.19807	2016-04-11 18:04:55.19807	\N	f	Fee::FixedFeeType	---\n- lgfs\n	\N	f
77	Trial	GTRL	2016-04-11 18:04:54.600111	2016-04-11 18:04:54.600111	9999.0	f	Fee::GraduatedFeeType	---\n- lgfs\n	\N	f
78	Retrial	GRTR	2016-04-11 18:04:54.656395	2016-04-11 18:04:54.656395	9999.0	f	Fee::GraduatedFeeType	---\n- lgfs\n	\N	f
25	Elected case not proceeded uplift	ENU	2015-11-05 17:08:50.621292	2016-03-02 11:22:58.98711	\N	t	Fee::FixedFeeType	---\n- agfs\n	\N	f
33	Adjourned appeals	SAF	2015-11-05 17:08:50.676743	2016-03-02 11:22:58.993692	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
36	Application to dismiss a charge (half day uplift)	PHU	2015-11-05 17:08:50.697175	2016-03-02 11:22:59.000447	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
1	Basic fee	BAF	2015-11-05 17:08:50.446583	2016-03-02 11:22:59.007076	9999.0	t	Fee::BasicFeeType	---\n- agfs\n	\N	f
22	Cracked case discontinued	CCD	2015-11-05 17:08:50.59171	2016-04-11 18:04:55.136406	\N	t	Fee::FixedFeeType	---\n- agfs\n- lgfs\n	\N	f
24	Elected case not proceeded	ENP	2015-11-05 17:08:50.614599	2016-04-11 18:04:55.151662	\N	t	Fee::FixedFeeType	---\n- agfs\n- lgfs\n	\N	f
87	Evidence provision fee	XEVI	2016-04-11 18:04:55.577483	2016-04-11 18:04:55.577483	\N	f	Fee::MiscFeeType	---\n- lgfs\n	\N	f
88	Costs judge application	XCJA	2016-04-11 18:04:55.587708	2016-04-11 18:04:55.587708	\N	f	Fee::MiscFeeType	---\n- lgfs\n	\N	f
89	Costs judge preparation	XCJP	2016-04-11 18:04:55.597252	2016-04-11 18:04:55.597252	\N	f	Fee::MiscFeeType	---\n- lgfs\n	\N	f
90	Case uplift	XUPL	2016-04-11 18:04:55.606936	2016-04-11 18:04:55.606936	\N	f	Fee::MiscFeeType	---\n- lgfs\n	\N	f
91	Warrant Fee	XWAR	2016-04-11 18:04:55.620925	2016-04-11 18:04:55.620925	\N	f	Fee::WarrantFeeType	---\n- lgfs\n	\N	f
85	Alteration of Crown Court sentence s155 Powers of Criminal Courts (Sentencing Act 2000)	XALT	2016-04-11 18:04:55.218611	2016-04-12 11:58:03.403172	\N	f	Fee::FixedFeeType	---\n- lgfs\n	83	f
86	Assistance by defendant: review of sentence s74 Serious Organised Crime and Police Act 2005	XASS	2016-04-11 18:04:55.228721	2016-04-12 11:58:03.41288	\N	f	Fee::FixedFeeType	---\n- lgfs\n	83	f
92	Contempt	ZCON	2016-04-13 09:00:27.072656	2016-04-13 09:00:27.072656	\N	t	Fee::FixedFeeType	---\n- agfs\n	\N	f
93	Effective PCMH	IPCMH	2016-05-26 17:00:57.585021	2016-05-26 17:00:57.585021	\N	f	Fee::InterimFeeType	---\n- lgfs\n	\N	f
94	Trial start	ITST	2016-05-26 17:00:57.615188	2016-05-26 17:00:57.615188	\N	f	Fee::InterimFeeType	---\n- lgfs\n	\N	f
95	Retrial New solicitor	IRNS	2016-05-26 17:00:57.82732	2016-05-26 17:00:57.82732	\N	f	Fee::InterimFeeType	---\n- lgfs\n	\N	f
96	Retrial start	IRST	2016-05-26 17:00:58.044427	2016-05-26 17:00:58.044427	\N	f	Fee::InterimFeeType	---\n- lgfs\n	\N	f
97	Disbursement only	IDISO	2016-05-26 17:00:58.831136	2016-05-26 17:00:58.831136	\N	f	Fee::InterimFeeType	---\n- lgfs\n	\N	f
98	Warrant	IWARR	2016-05-26 17:00:58.841716	2016-05-26 17:00:58.841716	\N	f	Fee::InterimFeeType	---\n- lgfs\n	\N	f
99	Transfer	TRANS	2016-05-26 17:00:58.860368	2016-05-26 17:00:58.860368	\N	f	Fee::TransferFeeType	---\n- lgfs\n	\N	f
65	Standard appearance fee uplift	SAU	2015-11-05 17:08:50.917115	2016-03-02 11:22:59.340092	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
66	Sentence hearings	SHR	2015-11-05 17:08:50.923742	2016-03-02 11:22:59.345583	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
67	Sentence hearings uplift	SHU	2015-11-05 17:08:50.930435	2016-03-02 11:22:59.350816	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
69	Trial not proceed	TNP	2015-11-05 17:08:50.943357	2016-03-02 11:22:59.361782	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
70	Trial not proceed uplift	TNU	2015-11-05 17:08:50.949997	2016-03-02 11:22:59.366994	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
71	Unsuccessful application to vacate a guilty plea (half day)	PAH	2015-11-05 17:08:50.956624	2016-03-02 11:22:59.372286	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
34	Application to dismiss a charge (half day)	PAH	2015-11-05 17:08:50.683454	2016-03-02 11:22:59.3778	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
10	Number of prosecution witnesses	NPW	2015-11-05 17:08:50.512796	2016-03-02 11:22:59.383344	\N	f	Fee::BasicFeeType	---\n- agfs\n	\N	f
35	Application to dismiss a charge (whole day)	PAW	2015-11-05 17:08:50.690406	2016-03-02 11:22:59.388964	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
37	Application to dismiss a charge (whole day uplift)	PWU	2015-11-05 17:08:50.704168	2016-03-02 11:22:59.394673	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
45	Hearings relating to admissibility of evidence (whole day)	AEW	2015-11-05 17:08:50.76717	2016-03-02 11:22:59.400251	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
72	Unsuccessful application to vacate a guilty plea (whole day)	PAW	2015-11-05 17:08:50.963125	2016-03-02 11:22:59.405825	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
73	Unsuccessful application to vacate a guilty plea (half day uplift)	PHU	2015-11-05 17:08:50.96979	2016-03-02 11:22:59.411962	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
74	Unsuccessful application to vacate a guilty plea (whole day uplift)	PWU	2015-11-05 17:08:50.977122	2016-03-02 11:22:59.417385	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	f
11	Pages of prosecution evidence	PPE	2015-11-05 17:08:50.51934	2016-03-02 11:22:59.433561	\N	f	Fee::BasicFeeType	---\n- agfs\n	\N	f
84	Vary/discharge an ASBO s1c Crime and Disorder Act 1998	XASB	2016-04-11 18:04:55.208555	2016-04-12 11:58:03.385793	\N	f	Fee::FixedFeeType	---\n- lgfs\n	83	f
79	Guilty plea	GGLTY	2016-04-11 18:04:54.692124	2016-04-11 18:04:54.692124	9999.0	f	Fee::GraduatedFeeType	---\n- lgfs\n	\N	f
80	Discontinuance	GDIS	2016-04-11 18:04:54.728143	2016-04-11 18:04:54.728143	9999.0	f	Fee::GraduatedFeeType	---\n- lgfs\n	\N	f
81	Cracked trial	GCRAK	2016-04-11 18:04:54.764484	2016-04-11 18:04:54.764484	9999.0	f	Fee::GraduatedFeeType	---\n- lgfs\n	\N	f
82	Cracked before retrial	GCBR	2016-04-11 18:04:54.808147	2016-04-11 18:04:54.808147	9999.0	f	Fee::GraduatedFeeType	---\n- lgfs\n	\N	f
68	Special preparation fee	SPF	2015-11-05 17:08:50.936752	2016-06-03 11:19:00.401444	\N	t	Fee::MiscFeeType	---\n- agfs\n- lgfs\n	\N	t
76	Wasted preparation fee	WPF	2015-11-05 17:08:50.998017	2016-06-03 11:19:00.40774	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	t
63	Research of very unusual or novel factual issue	RNF	2015-11-05 17:08:50.903838	2016-06-03 11:19:00.412831	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	t
7	Conferences and views	CAV	2015-11-05 17:08:50.491885	2016-06-03 11:19:00.422214	\N	t	Fee::BasicFeeType	---\n- agfs\n	\N	t
75	Written / oral advice	WOA	2015-11-05 17:08:50.991085	2016-06-03 11:19:00.427563	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	t
64	Research of very unusual or novel point of law	RNL	2015-11-05 17:08:50.910546	2016-06-09 14:16:51.650438	\N	t	Fee::MiscFeeType	---\n- agfs\n	\N	t
\.


--
-- Name: fee_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: stephenrichards
--

SELECT pg_catalog.setval('fee_types_id_seq', 99, true);


--
-- Data for Name: offence_classes; Type: TABLE DATA; Schema: public; Owner: stephenrichards
--

COPY offence_classes (id, class_letter, description, created_at, updated_at) FROM stdin;
1	A	Homicide and related grave offences	2015-11-05 17:08:47.294606	2015-11-05 17:08:47.294606
2	B	Offences involving serious violence or damage and serious drug offences	2015-11-05 17:08:47.301874	2015-11-05 17:08:47.301874
3	C	Lesser offences involving violence or damage and less serious drug offences	2015-11-05 17:08:47.307907	2015-11-05 17:08:47.307907
4	D	Serious sexual offences and offences against children	2015-11-05 17:08:47.313898	2015-11-05 17:08:47.313898
5	E	Burglary	2015-11-05 17:08:47.320072	2015-11-05 17:08:47.320072
6	F	Other offences of dishonesty up to £30,000	2015-11-05 17:08:47.326037	2015-11-05 17:08:47.326037
7	G	Other offences of dishonesty between £30,001 and £100,000	2015-11-05 17:08:47.331848	2015-11-05 17:08:47.331848
8	H	Miscellaneous lesser offences	2015-11-05 17:08:47.33762	2015-11-05 17:08:47.33762
9	I	Offences against public justice and similar offences	2015-11-05 17:08:47.345589	2015-11-05 17:08:47.345589
10	J	Serious sexual offences, offences against children	2015-11-05 17:08:47.351596	2015-11-05 17:08:47.351596
11	K	Offences of dishonesty in Class F where the value in is in excess of £100,000	2015-11-05 17:08:47.357473	2015-11-05 17:08:47.357473
\.


--
-- Name: offence_classes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: stephenrichards
--

SELECT pg_catalog.setval('offence_classes_id_seq', 11, true);


--
-- Data for Name: offences; Type: TABLE DATA; Schema: public; Owner: stephenrichards
--

COPY offences (id, description, offence_class_id, created_at, updated_at) FROM stdin;
1	Abandonment of children under two	3	2015-11-05 17:08:47.491611	2015-11-05 17:08:47.491611
2	Abduction of defective from parent	4	2015-11-05 17:08:47.499931	2015-11-05 17:08:47.499931
3	Abduction of unmarried girl under 16 from parent	10	2015-11-05 17:08:47.506769	2015-11-05 17:08:47.506769
4	Abduction of unmarried girl under 18 from parent	4	2015-11-05 17:08:47.512938	2015-11-05 17:08:47.512938
5	Abduction of woman by force	10	2015-11-05 17:08:47.519383	2015-11-05 17:08:47.519383
6	Abstraction of electricity	6	2015-11-05 17:08:47.526248	2015-11-05 17:08:47.526248
7	Abstraction of electricity	7	2015-11-05 17:08:47.532966	2015-11-05 17:08:47.532966
8	Abstraction of electricity	11	2015-11-05 17:08:47.540032	2015-11-05 17:08:47.540032
9	Abuse of position of trust	4	2015-11-05 17:08:47.54757	2015-11-05 17:08:47.54757
10	Abuse of position of trust: causing a child to engage in sexual activity	4	2015-11-05 17:08:47.553824	2015-11-05 17:08:47.553824
11	Abuse of position of trust: causing a child to watch sexual activity	4	2015-11-05 17:08:47.56019	2015-11-05 17:08:47.56019
12	Abuse of trust: sexual activity in the presence of a child	4	2015-11-05 17:08:47.566692	2015-11-05 17:08:47.566692
13	Abuse of trust: sexual activity with a child	4	2015-11-05 17:08:47.573535	2015-11-05 17:08:47.573535
14	Acquisition by or supply of firearms to person denied them	3	2015-11-05 17:08:47.580248	2015-11-05 17:08:47.580248
15	Acquisition, use or possession of criminal property	2	2015-11-05 17:08:47.586985	2015-11-05 17:08:47.586985
16	Activities relating to opium	2	2015-11-05 17:08:47.593457	2015-11-05 17:08:47.593457
17	Acts outraging public decency	8	2015-11-05 17:08:47.633306	2015-11-05 17:08:47.633306
18	Administering a substance with intent	4	2015-11-05 17:08:47.639755	2015-11-05 17:08:47.639755
19	Administering chloroform, laudanum etc.	2	2015-11-05 17:08:47.646959	2015-11-05 17:08:47.646959
20	Administering drugs to obtain intercourse	4	2015-11-05 17:08:47.653403	2015-11-05 17:08:47.653403
21	Administering poison etc. so as to endanger life	2	2015-11-05 17:08:47.659709	2015-11-05 17:08:47.659709
22	Administering poison with intent to injure etc.	3	2015-11-05 17:08:47.666056	2015-11-05 17:08:47.666056
23	Affray	8	2015-11-05 17:08:47.672406	2015-11-05 17:08:47.672406
24	Aggravated arson	2	2015-11-05 17:08:47.678515	2015-11-05 17:08:47.678515
25	Aggravated burglary	2	2015-11-05 17:08:47.684607	2015-11-05 17:08:47.684607
26	Aggravated criminal damage	2	2015-11-05 17:08:47.690929	2015-11-05 17:08:47.690929
27	Aggravated vehicle taking	8	2015-11-05 17:08:47.696896	2015-11-05 17:08:47.696896
28	Aggravated vehicle taking resulting in death	2	2015-11-05 17:08:47.703235	2015-11-05 17:08:47.703235
29	Agreeing to indemnify sureties	8	2015-11-05 17:08:47.709736	2015-11-05 17:08:47.709736
30	Aiding and abetting suicide	2	2015-11-05 17:08:47.715994	2015-11-05 17:08:47.715994
31	Allowing or procuring child under 16 to go abroad to perform	10	2015-11-05 17:08:47.722689	2015-11-05 17:08:47.722689
32	Allowing the death of a child	2	2015-11-05 17:08:47.729211	2015-11-05 17:08:47.729211
33	Armed robbery	2	2015-11-05 17:08:47.736795	2015-11-05 17:08:47.736795
34	Arranging child sex offence	10	2015-11-05 17:08:47.743473	2015-11-05 17:08:47.743473
35	Arson (other than aggravated arson) where value does not exceed £30,000	3	2015-11-05 17:08:47.750792	2015-11-05 17:08:47.750792
36	Arson (where value exceeds £30,000)	2	2015-11-05 17:08:47.757256	2015-11-05 17:08:47.757256
37	Assault by penetration	10	2015-11-05 17:08:47.763716	2015-11-05 17:08:47.763716
38	Assault occasioning actual bodily harm	3	2015-11-05 17:08:47.77009	2015-11-05 17:08:47.77009
39	Assault of child under 13 by penetration	10	2015-11-05 17:08:47.776385	2015-11-05 17:08:47.776385
40	Assault with intent to commit buggery	10	2015-11-05 17:08:47.782764	2015-11-05 17:08:47.782764
41	Assault with intent to resist arrest	8	2015-11-05 17:08:47.789134	2015-11-05 17:08:47.789134
42	Assault with weapon with intent to rob	2	2015-11-05 17:08:47.795563	2015-11-05 17:08:47.795563
43	Assaulting prison officer whilst possessing firearm etc.	2	2015-11-05 17:08:47.801887	2015-11-05 17:08:47.801887
44	Assaults on officers saving wrecks	3	2015-11-05 17:08:47.807981	2015-11-05 17:08:47.807981
45	Assisting illegal entry or harbouring persons	3	2015-11-05 17:08:47.816469	2015-11-05 17:08:47.816469
46	Assisting offenders	9	2015-11-05 17:08:47.824211	2015-11-05 17:08:47.824211
47	Assisting prisoners to escape	3	2015-11-05 17:08:47.835906	2015-11-05 17:08:47.835906
48	Attempt to cause explosion, making or keeping explosive etc.	1	2015-11-05 17:08:47.84258	2015-11-05 17:08:47.84258
49	Attempting to choke, suffocate, strangle etc.	2	2015-11-05 17:08:47.853605	2015-11-05 17:08:47.853605
50	Attempting to injure or alarm the Sovereign	3	2015-11-05 17:08:47.864566	2015-11-05 17:08:47.864566
51	Being drunk on an aircraft	8	2015-11-05 17:08:47.87258	2015-11-05 17:08:47.87258
52	Blackmail	2	2015-11-05 17:08:47.884581	2015-11-05 17:08:47.884581
53	Bomb hoax	3	2015-11-05 17:08:47.890794	2015-11-05 17:08:47.890794
54	Breach of anti-social behaviour order	8	2015-11-05 17:08:47.904212	2015-11-05 17:08:47.904212
55	Breach of harassment injunction	8	2015-11-05 17:08:47.91038	2015-11-05 17:08:47.91038
56	Breach of prison	3	2015-11-05 17:08:47.919095	2015-11-05 17:08:47.919095
57	Breach of restraining order	8	2015-11-05 17:08:47.925379	2015-11-05 17:08:47.925379
58	Breach of sex offender order	8	2015-11-05 17:08:47.931954	2015-11-05 17:08:47.931954
59	Breaking or injuring submarine telegraph cables	3	2015-11-05 17:08:47.938857	2015-11-05 17:08:47.938857
60	Buggery of males of 16 or over otherwise than in private	8	2015-11-05 17:08:47.945288	2015-11-05 17:08:47.945288
61	Buggery of person under 16	10	2015-11-05 17:08:47.952659	2015-11-05 17:08:47.952659
62	Burglary (domestic)	5	2015-11-05 17:08:47.959794	2015-11-05 17:08:47.959794
63	Burglary (non-domestic)	5	2015-11-05 17:08:47.966164	2015-11-05 17:08:47.966164
64	Care workers: causing a person with a mental disorder to watch a sexual act	4	2015-11-05 17:08:47.972442	2015-11-05 17:08:47.972442
65	Care workers: inciting person with mental disorder to engage in sexual act	10	2015-11-05 17:08:47.978694	2015-11-05 17:08:47.978694
66	Care workers: sexual activity in presence of a person with a mental disorder	4	2015-11-05 17:08:47.985242	2015-11-05 17:08:47.985242
67	Care workers: sexual activity with a person with a mental disorder	10	2015-11-05 17:08:47.991636	2015-11-05 17:08:47.991636
68	Carrying loaded firearm in public place	3	2015-11-05 17:08:47.998163	2015-11-05 17:08:47.998163
69	Causing a child to engage in sexual activity	10	2015-11-05 17:08:48.004548	2015-11-05 17:08:48.004548
70	Causing a child to watch a sexual act	4	2015-11-05 17:08:48.011051	2015-11-05 17:08:48.011051
71	Causing a child under 13 to engage in sexual activity	10	2015-11-05 17:08:48.017154	2015-11-05 17:08:48.017154
72	Causing a person with a mental disorder to watch a sexual act	4	2015-11-05 17:08:48.023247	2015-11-05 17:08:48.023247
73	Causing bodily injury by explosives	2	2015-11-05 17:08:48.03262	2015-11-05 17:08:48.03262
74	Causing danger to road users	2	2015-11-05 17:08:48.039325	2015-11-05 17:08:48.039325
75	Causing death by careless driving while under the influence of drink or drugs	2	2015-11-05 17:08:48.045337	2015-11-05 17:08:48.045337
76	Causing death by dangerous driving	2	2015-11-05 17:08:48.053288	2015-11-05 17:08:48.053288
77	Causing explosion likely to endanger life or property	1	2015-11-05 17:08:48.059753	2015-11-05 17:08:48.059753
78	Causing miscarriage by poison, instrument	2	2015-11-05 17:08:48.066166	2015-11-05 17:08:48.066166
79	Causing or allowing the death of a child	2	2015-11-05 17:08:48.073114	2015-11-05 17:08:48.073114
80	Causing or encouraging prostitution of defective	4	2015-11-05 17:08:48.079937	2015-11-05 17:08:48.079937
81	Causing or encouraging prostitution of girl under 16	10	2015-11-05 17:08:48.086199	2015-11-05 17:08:48.086199
82	Causing or inciting a person with a mental disorder to engage in sexual activity	10	2015-11-05 17:08:48.092811	2015-11-05 17:08:48.092811
83	Causing or inciting child prostitution or pornography	10	2015-11-05 17:08:48.099078	2015-11-05 17:08:48.099078
84	Causing or inciting prostitution for gain	4	2015-11-05 17:08:48.105449	2015-11-05 17:08:48.105449
85	Causing prostitution of women	8	2015-11-05 17:08:48.120311	2015-11-05 17:08:48.120311
86	Causing sexual activity with penetration	10	2015-11-05 17:08:48.127164	2015-11-05 17:08:48.127164
87	Causing sexual activity without penetration	4	2015-11-05 17:08:48.133486	2015-11-05 17:08:48.133486
88	Child abduction by connected person	3	2015-11-05 17:08:48.140256	2015-11-05 17:08:48.140256
89	Child abduction by other person	3	2015-11-05 17:08:48.146689	2015-11-05 17:08:48.146689
90	Child destruction	1	2015-11-05 17:08:48.153141	2015-11-05 17:08:48.153141
91	Child sex offence committed by person under 18	4	2015-11-05 17:08:48.159616	2015-11-05 17:08:48.159616
92	Circumcision of females	3	2015-11-05 17:08:48.165598	2015-11-05 17:08:48.165598
93	Committing offence with intent to commit sexual offence	4	2015-11-05 17:08:48.171735	2015-11-05 17:08:48.171735
94	Concealing an arrestable offence	9	2015-11-05 17:08:48.177733	2015-11-05 17:08:48.177733
95	Concealing criminal property	2	2015-11-05 17:08:48.183788	2015-11-05 17:08:48.183788
96	Concealment of birth	3	2015-11-05 17:08:48.190308	2015-11-05 17:08:48.190308
97	Conspiring to commit offences outside the United Kingdom	9	2015-11-05 17:08:48.196675	2015-11-05 17:08:48.196675
98	Contamination of goods with intent	2	2015-11-05 17:08:48.202771	2015-11-05 17:08:48.202771
99	Controlling a child prostitute	10	2015-11-05 17:08:48.208995	2015-11-05 17:08:48.208995
100	Controlling prostitution for gain	4	2015-11-05 17:08:48.215285	2015-11-05 17:08:48.215285
101	Copying false instrument with intent	6	2015-11-05 17:08:48.221335	2015-11-05 17:08:48.221335
102	Copying false instrument with intent	7	2015-11-05 17:08:48.22764	2015-11-05 17:08:48.22764
103	Copying false instrument with intent	11	2015-11-05 17:08:48.234059	2015-11-05 17:08:48.234059
104	Corrupt transactions with agents	9	2015-11-05 17:08:48.240824	2015-11-05 17:08:48.240824
105	Corruption in public office	9	2015-11-05 17:08:48.247127	2015-11-05 17:08:48.247127
106	Counterfeiting Customs documents	6	2015-11-05 17:08:48.253896	2015-11-05 17:08:48.253896
107	Counterfeiting Customs documents	7	2015-11-05 17:08:48.260201	2015-11-05 17:08:48.260201
108	Counterfeiting Customs documents	11	2015-11-05 17:08:48.26657	2015-11-05 17:08:48.26657
109	Counterfeiting notes and coins	7	2015-11-05 17:08:48.272678	2015-11-05 17:08:48.272678
110	Counterfeiting of dies or marks	6	2015-11-05 17:08:48.282771	2015-11-05 17:08:48.282771
111	Counterfeiting of dies or marks	7	2015-11-05 17:08:48.343571	2015-11-05 17:08:48.343571
112	Counterfeiting of dies or marks	11	2015-11-05 17:08:48.350274	2015-11-05 17:08:48.350274
113	Criminal damage (other than aggravated criminal damage)	3	2015-11-05 17:08:48.357127	2015-11-05 17:08:48.357127
114	Cruelty to persons under 16	2	2015-11-05 17:08:48.363307	2015-11-05 17:08:48.363307
115	Cultivation of cannabis plant	2	2015-11-05 17:08:48.369854	2015-11-05 17:08:48.369854
116	Custody or control of false instruments etc.	6	2015-11-05 17:08:48.37997	2015-11-05 17:08:48.37997
117	Custody or control of false instruments etc.	7	2015-11-05 17:08:48.386621	2015-11-05 17:08:48.386621
118	Custody or control of false instruments etc.	11	2015-11-05 17:08:48.393024	2015-11-05 17:08:48.393024
119	Dangerous driving	8	2015-11-05 17:08:48.399533	2015-11-05 17:08:48.399533
120	Dealing in firearms	3	2015-11-05 17:08:48.405676	2015-11-05 17:08:48.405676
121	Destruction of registers of births etc.	6	2015-11-05 17:08:48.412111	2015-11-05 17:08:48.412111
122	Detention of woman in brothel or other premises	8	2015-11-05 17:08:48.418546	2015-11-05 17:08:48.418546
123	Directing terrorist organisation	2	2015-11-05 17:08:48.42504	2015-11-05 17:08:48.42504
124	Disclosure prejudicing, or interference of material relevant to, investigation of terrorism	2	2015-11-05 17:08:48.431465	2015-11-05 17:08:48.431465
125	Disclosure under sections 330, 331, 332 or 333 of the Proceeds of Crime Act 2002 otherwise than in the form and manner prescribed	2	2015-11-05 17:08:48.437809	2015-11-05 17:08:48.437809
126	Drug trafficking offences at sea	2	2015-11-05 17:08:48.444047	2015-11-05 17:08:48.444047
127	Embracery	9	2015-11-05 17:08:48.450447	2015-11-05 17:08:48.450447
128	Endangering the safety of an aircraft	2	2015-11-05 17:08:48.457164	2015-11-05 17:08:48.457164
129	Endangering the safety of railway passengers	2	2015-11-05 17:08:48.464274	2015-11-05 17:08:48.464274
130	Engaging in sexual activity in the presence of a child	4	2015-11-05 17:08:48.4704	2015-11-05 17:08:48.4704
131	Engaging in sexual activity in the presence of a person with a mental disorder	4	2015-11-05 17:08:48.476496	2015-11-05 17:08:48.476496
132	Escaping from lawful custody without force	3	2015-11-05 17:08:48.485277	2015-11-05 17:08:48.485277
133	Evasion of liability by deception	6	2015-11-05 17:08:48.491611	2015-11-05 17:08:48.491611
134	Evasion of liability by deception	7	2015-11-05 17:08:48.497919	2015-11-05 17:08:48.497919
135	Evasion of liability by deception	11	2015-11-05 17:08:48.50481	2015-11-05 17:08:48.50481
136	Exposure	4	2015-11-05 17:08:48.510954	2015-11-05 17:08:48.510954
137	Fabrication of evidence with intent to mislead a tribunal	9	2015-11-05 17:08:48.517047	2015-11-05 17:08:48.517047
138	Facilitating child prostitution	10	2015-11-05 17:08:48.523564	2015-11-05 17:08:48.523564
139	Failing to keep dogs under proper control resulting in injury	3	2015-11-05 17:08:48.52986	2015-11-05 17:08:48.52986
140	Failure to comply with certificate when transferring firearm	3	2015-11-05 17:08:48.536754	2015-11-05 17:08:48.536754
141	Failure to disclose information about terrorism	3	2015-11-05 17:08:48.543156	2015-11-05 17:08:48.543156
142	Failure to disclose knowledge or suspicion of money laundering	3	2015-11-05 17:08:48.549651	2015-11-05 17:08:48.549651
143	Failure to disclose knowledge or suspicion of money laundering: nominated officers in the regulated sector	2	2015-11-05 17:08:48.556975	2015-11-05 17:08:48.556975
144	Failure to disclose knowledge or suspicion of money laundering: other nominated officers	2	2015-11-05 17:08:48.563193	2015-11-05 17:08:48.563193
145	Failure to disclose knowledge or suspicion of money laundering: regulated sector	2	2015-11-05 17:08:48.569446	2015-11-05 17:08:48.569446
146	False accounting	6	2015-11-05 17:08:48.575704	2015-11-05 17:08:48.575704
147	False accounting	7	2015-11-05 17:08:48.581807	2015-11-05 17:08:48.581807
148	False accounting	11	2015-11-05 17:08:48.587963	2015-11-05 17:08:48.587963
149	False evidence before European Court	9	2015-11-05 17:08:48.594221	2015-11-05 17:08:48.594221
150	False imprisonment	2	2015-11-05 17:08:48.600591	2015-11-05 17:08:48.600591
151	False statement tendered under section 5B of the Magistrates' Courts Act 1980	9	2015-11-05 17:08:48.606881	2015-11-05 17:08:48.606881
152	False statement tendered under section 9 of the Criminal Justice Act 1967	9	2015-11-05 17:08:48.613359	2015-11-05 17:08:48.613359
153	Firing on Revenue vessel	2	2015-11-05 17:08:48.619746	2015-11-05 17:08:48.619746
154	Forgery	6	2015-11-05 17:08:48.625997	2015-11-05 17:08:48.625997
155	Forgery	7	2015-11-05 17:08:48.63213	2015-11-05 17:08:48.63213
156	Forgery	11	2015-11-05 17:08:48.640594	2015-11-05 17:08:48.640594
157	Forgery and misuse of driving documents	8	2015-11-05 17:08:48.647497	2015-11-05 17:08:48.647497
158	Forgery etc. of licences and other documents	8	2015-11-05 17:08:48.65418	2015-11-05 17:08:48.65418
159	Forgery of driving documents	8	2015-11-05 17:08:48.660305	2015-11-05 17:08:48.660305
160	Forgery, alteration, fraud of licences etc.	8	2015-11-05 17:08:48.666579	2015-11-05 17:08:48.666579
161	Fraud by abuse of position	6	2015-11-05 17:08:48.673009	2015-11-05 17:08:48.673009
162	Fraud by abuse of position	7	2015-11-05 17:08:48.679199	2015-11-05 17:08:48.679199
163	Fraud by abuse of position	11	2015-11-05 17:08:48.685293	2015-11-05 17:08:48.685293
164	Fraud by failing to disclose information	6	2015-11-05 17:08:48.691429	2015-11-05 17:08:48.691429
165	Fraud by failing to disclose information	7	2015-11-05 17:08:48.697659	2015-11-05 17:08:48.697659
166	Fraud by failing to disclose information	11	2015-11-05 17:08:48.704298	2015-11-05 17:08:48.704298
167	Fraud by false representation	6	2015-11-05 17:08:48.710509	2015-11-05 17:08:48.710509
168	Fraud by false representation	7	2015-11-05 17:08:48.718317	2015-11-05 17:08:48.718317
169	Fraud by false representation	11	2015-11-05 17:08:48.724466	2015-11-05 17:08:48.724466
170	Fraudulent evasion of agricultural levy	3	2015-11-05 17:08:48.730602	2015-11-05 17:08:48.730602
171	Fraudulent evasion of controls on Class A and B drugs	2	2015-11-05 17:08:48.736937	2015-11-05 17:08:48.736937
172	Fraudulent evasion of controls on Class C drugs	3	2015-11-05 17:08:48.743875	2015-11-05 17:08:48.743875
173	Fraudulent evasion of duty	6	2015-11-05 17:08:48.750324	2015-11-05 17:08:48.750324
174	Fraudulent evasion of duty	7	2015-11-05 17:08:48.75722	2015-11-05 17:08:48.75722
175	Fraudulent evasion of duty	11	2015-11-05 17:08:48.763763	2015-11-05 17:08:48.763763
176	Fraudulent evasion: counterfeit notes or coins	7	2015-11-05 17:08:48.770278	2015-11-05 17:08:48.770278
177	Fraudulent evasion: not elsewhere specified	6	2015-11-05 17:08:48.77763	2015-11-05 17:08:48.77763
178	Fraudulent evasion: not elsewhere specified	7	2015-11-05 17:08:48.784799	2015-11-05 17:08:48.784799
179	Fraudulent evasion: not elsewhere specified	11	2015-11-05 17:08:48.791482	2015-11-05 17:08:48.791482
180	Fund-raising for terrorism	2	2015-11-05 17:08:48.799978	2015-11-05 17:08:48.799978
181	Giving false statements to procure cremation	9	2015-11-05 17:08:48.807273	2015-11-05 17:08:48.807273
182	Going equipped to steal	5	2015-11-05 17:08:48.825036	2015-11-05 17:08:48.825036
183	Gross indecency between male of 21 or over and male under 16	4	2015-11-05 17:08:48.832287	2015-11-05 17:08:48.832287
184	Gross indecency between males (other than where one is 21 or over and the other is under 16)	8	2015-11-05 17:08:48.838751	2015-11-05 17:08:48.838751
185	Handling stolen goods	6	2015-11-05 17:08:48.844986	2015-11-05 17:08:48.844986
186	Handling stolen goods	7	2015-11-05 17:08:48.851345	2015-11-05 17:08:48.851345
187	Handling stolen goods	11	2015-11-05 17:08:48.858147	2015-11-05 17:08:48.858147
188	Harbouring escaped prisoners	3	2015-11-05 17:08:48.865744	2015-11-05 17:08:48.865744
189	Harming, threatening to harm a witness, juror etc.	9	2015-11-05 17:08:48.872223	2015-11-05 17:08:48.872223
190	Having an article with a blade or point in a public place	8	2015-11-05 17:08:48.880727	2015-11-05 17:08:48.880727
191	Hostage taking	2	2015-11-05 17:08:48.886916	2015-11-05 17:08:48.886916
192	Illegal importation of Class A and B drugs	2	2015-11-05 17:08:48.89293	2015-11-05 17:08:48.89293
193	Illegal importation of Class C drugs	3	2015-11-05 17:08:48.899123	2015-11-05 17:08:48.899123
194	Illegal importation: counterfeit notes or coins	7	2015-11-05 17:08:48.905437	2015-11-05 17:08:48.905437
195	Illegal importation: not elsewhere specified	6	2015-11-05 17:08:48.91182	2015-11-05 17:08:48.91182
196	Illegal importation: not elsewhere specified	7	2015-11-05 17:08:48.918341	2015-11-05 17:08:48.918341
197	Illegal importation: not elsewhere specified	11	2015-11-05 17:08:48.925766	2015-11-05 17:08:48.925766
198	Ill-treatment of persons of unsound mind	4	2015-11-05 17:08:48.932439	2015-11-05 17:08:48.932439
199	Impeding persons endeavouring to escape wrecks	2	2015-11-05 17:08:48.938664	2015-11-05 17:08:48.938664
200	Impersonating Customs officer	8	2015-11-05 17:08:48.945571	2015-11-05 17:08:48.945571
201	Incest by man with a girl under 13	10	2015-11-05 17:08:48.951801	2015-11-05 17:08:48.951801
202	Incest other than by man with a girl under 13	4	2015-11-05 17:08:48.96026	2015-11-05 17:08:48.96026
203	Incitement of terrorism overseas	2	2015-11-05 17:08:48.966409	2015-11-05 17:08:48.966409
204	Incitement to commit incest	4	2015-11-05 17:08:48.97252	2015-11-05 17:08:48.97252
205	Inciting a child family member to engage in sexual activity	10	2015-11-05 17:08:48.978673	2015-11-05 17:08:48.978673
206	Indecency with children under 14	10	2015-11-05 17:08:48.985089	2015-11-05 17:08:48.985089
207	Indecent assault on a man	4	2015-11-05 17:08:48.991613	2015-11-05 17:08:48.991613
208	Indecent assault on a woman	4	2015-11-05 17:08:48.998374	2015-11-05 17:08:48.998374
209	Indecent display	8	2015-11-05 17:08:49.004663	2015-11-05 17:08:49.004663
210	Inducing person with mental disorder to engage in sexual activity	10	2015-11-05 17:08:49.011125	2015-11-05 17:08:49.011125
211	Infanticide	1	2015-11-05 17:08:49.017358	2015-11-05 17:08:49.017358
212	Intercourse with an animal	4	2015-11-05 17:08:49.023597	2015-11-05 17:08:49.023597
213	Intimidating a witness, juror etc.	9	2015-11-05 17:08:49.031906	2015-11-05 17:08:49.031906
214	Involvement in arrangements facilitating the acquisition, retention, use or control of criminal property	2	2015-11-05 17:08:49.038194	2015-11-05 17:08:49.038194
215	Keeping a disorderly house	8	2015-11-05 17:08:49.044651	2015-11-05 17:08:49.044651
216	Kidnapping	2	2015-11-05 17:08:49.051308	2015-11-05 17:08:49.051308
217	Living on earnings of male prostitution	4	2015-11-05 17:08:49.058805	2015-11-05 17:08:49.058805
218	Making a false statement to obtain interim possession order	9	2015-11-05 17:08:49.06554	2015-11-05 17:08:49.06554
219	Making false entries in copies of registers sent to register	6	2015-11-05 17:08:49.07949	2015-11-05 17:08:49.07949
220	Making false statement to authorised officer	9	2015-11-05 17:08:49.086213	2015-11-05 17:08:49.086213
221	Making false statement to resist making of interim possession order	9	2015-11-05 17:08:49.092584	2015-11-05 17:08:49.092584
222	Making gunpowder etc. to commit offences	3	2015-11-05 17:08:49.099581	2015-11-05 17:08:49.099581
223	Making off without payment	8	2015-11-05 17:08:49.105765	2015-11-05 17:08:49.105765
224	Making or possession of explosive in suspicious circumstances	2	2015-11-05 17:08:49.113695	2015-11-05 17:08:49.113695
225	Making or supplying articles for use in frauds	6	2015-11-05 17:08:49.120525	2015-11-05 17:08:49.120525
226	Making or supplying articles for use in frauds	7	2015-11-05 17:08:49.127622	2015-11-05 17:08:49.127622
227	Making or supplying articles for use in frauds	11	2015-11-05 17:08:49.134717	2015-11-05 17:08:49.134717
228	Making threats to destroy or damage property	3	2015-11-05 17:08:49.141137	2015-11-05 17:08:49.141137
229	Making threats to kill	2	2015-11-05 17:08:49.147483	2015-11-05 17:08:49.147483
230	Making, custody or control of counterfeiting materials etc.	7	2015-11-05 17:08:49.154077	2015-11-05 17:08:49.154077
231	Man living on earnings of prostitution	4	2015-11-05 17:08:49.161028	2015-11-05 17:08:49.161028
232	Manslaughter	1	2015-11-05 17:08:49.167672	2015-11-05 17:08:49.167672
233	Manufacture and supply of scheduled substances	2	2015-11-05 17:08:49.174125	2015-11-05 17:08:49.174125
234	Meeting child following sexual grooming	4	2015-11-05 17:08:49.180928	2015-11-05 17:08:49.180928
235	Membership of proscribed organisations	2	2015-11-05 17:08:49.187453	2015-11-05 17:08:49.187453
236	Misconduct endangering ship or persons on board ship	8	2015-11-05 17:08:49.193848	2015-11-05 17:08:49.193848
237	Mishandling or falsifying parking documents etc.	8	2015-11-05 17:08:49.200226	2015-11-05 17:08:49.200226
238	Murder	1	2015-11-05 17:08:49.206635	2015-11-05 17:08:49.206635
239	Neglecting to provide food for or assaulting servants etc.	3	2015-11-05 17:08:49.22394	2015-11-05 17:08:49.22394
240	Obscene articles intended for publication for gain	8	2015-11-05 17:08:49.230869	2015-11-05 17:08:49.230869
241	Obstructing Customs officer	8	2015-11-05 17:08:49.237754	2015-11-05 17:08:49.237754
242	Obstructing engine or carriage on railway	8	2015-11-05 17:08:49.244386	2015-11-05 17:08:49.244386
243	Obtaining pecuniary advantage by deception	6	2015-11-05 17:08:49.251482	2015-11-05 17:08:49.251482
244	Obtaining pecuniary advantage by deception	7	2015-11-05 17:08:49.258178	2015-11-05 17:08:49.258178
245	Obtaining pecuniary advantage by deception	11	2015-11-05 17:08:49.265629	2015-11-05 17:08:49.265629
246	Obtaining property by deception	6	2015-11-05 17:08:49.272256	2015-11-05 17:08:49.272256
247	Obtaining property by deception	7	2015-11-05 17:08:49.278687	2015-11-05 17:08:49.278687
248	Obtaining property by deception	11	2015-11-05 17:08:49.285225	2015-11-05 17:08:49.285225
249	Obtaining services by deception	6	2015-11-05 17:08:49.291565	2015-11-05 17:08:49.291565
250	Obtaining services by deception	7	2015-11-05 17:08:49.297924	2015-11-05 17:08:49.297924
251	Obtaining services by deception	11	2015-11-05 17:08:49.304176	2015-11-05 17:08:49.304176
255	Occupier knowingly permitting drugs offences etc.	2	2015-11-05 17:08:49.340994	2015-11-05 17:08:49.340994
256	Offences against international protection of nuclear material	2	2015-11-05 17:08:49.348378	2015-11-05 17:08:49.348378
257	Offences in relation to dies or stamps	6	2015-11-05 17:08:49.354972	2015-11-05 17:08:49.354972
258	Offences in relation to dies or stamps	7	2015-11-05 17:08:49.362299	2015-11-05 17:08:49.362299
259	Offences in relation to dies or stamps	11	2015-11-05 17:08:49.368721	2015-11-05 17:08:49.368721
260	Offences in relation to money laundering investigations	2	2015-11-05 17:08:49.374972	2015-11-05 17:08:49.374972
261	Offences in relation to proceeds of drug trafficking	2	2015-11-05 17:08:49.381228	2015-11-05 17:08:49.381228
262	Offences involving custody or control of counterfeit notes and coins	7	2015-11-05 17:08:49.38755	2015-11-05 17:08:49.38755
263	Offences of publication of obscene matter	8	2015-11-05 17:08:49.394067	2015-11-05 17:08:49.394067
264	Offences relating to the safe custody of controlled drugs	8	2015-11-05 17:08:49.401124	2015-11-05 17:08:49.401124
265	Offender armed or disguised	3	2015-11-05 17:08:49.407512	2015-11-05 17:08:49.407512
266	Offering inducement to procure sexual activity with a person with a mental disorder	10	2015-11-05 17:08:49.413782	2015-11-05 17:08:49.413782
267	Other offences involving money or property to be used for terrorism	2	2015-11-05 17:08:49.42014	2015-11-05 17:08:49.42014
268	Participating in fraudulent business carried on by sole trader etc.	6	2015-11-05 17:08:49.426493	2015-11-05 17:08:49.426493
269	Participating in fraudulent business carried on by sole trader etc.	7	2015-11-05 17:08:49.432687	2015-11-05 17:08:49.432687
270	Participating in fraudulent business carried on by sole trader etc.	11	2015-11-05 17:08:49.438997	2015-11-05 17:08:49.438997
271	Passing counterfeit notes and coins	7	2015-11-05 17:08:49.445264	2015-11-05 17:08:49.445264
272	Paying for sexual services of a child	10	2015-11-05 17:08:49.451529	2015-11-05 17:08:49.451529
273	Perjuries (7 offences)	9	2015-11-05 17:08:49.458268	2015-11-05 17:08:49.458268
274	Permitting an escape	3	2015-11-05 17:08:49.465059	2015-11-05 17:08:49.465059
275	Permitting defective to use premises for intercourse	4	2015-11-05 17:08:49.471705	2015-11-05 17:08:49.471705
276	Permitting girl under 13 to use premises for sexual intercourse	10	2015-11-05 17:08:49.47813	2015-11-05 17:08:49.47813
277	Permitting girl under 16 to use premises for intercourse	10	2015-11-05 17:08:49.484533	2015-11-05 17:08:49.484533
278	Personating for purposes of bail etc.	9	2015-11-05 17:08:49.506609	2015-11-05 17:08:49.506609
279	Personation of jurors	9	2015-11-05 17:08:49.513299	2015-11-05 17:08:49.513299
280	Perverting the course of public justice	9	2015-11-05 17:08:49.526336	2015-11-05 17:08:49.526336
281	Placing explosives with intent to cause bodily injury	2	2015-11-05 17:08:49.53338	2015-11-05 17:08:49.53338
282	Possessing anything with intent to destroy or damage property	3	2015-11-05 17:08:49.53955	2015-11-05 17:08:49.53955
283	Possession (with intention) of apparatus or material for making false identity documents	6	2015-11-05 17:08:49.545655	2015-11-05 17:08:49.545655
284	Possession (with intention) of false identity documents	6	2015-11-05 17:08:49.552032	2015-11-05 17:08:49.552032
285	Possession of false identify documents	6	2015-11-05 17:08:49.558771	2015-11-05 17:08:49.558771
286	Possession (without reasonable excuse) of false identity documents or apparatus or material for making false identity documents	6	2015-11-05 17:08:49.565647	2015-11-05 17:08:49.565647
287	Possession etc of articles for use in frauds	6	2015-11-05 17:08:49.572907	2015-11-05 17:08:49.572907
288	Possession etc of articles for use in frauds	7	2015-11-05 17:08:49.579696	2015-11-05 17:08:49.579696
289	Possession etc of articles for use in frauds	11	2015-11-05 17:08:49.586008	2015-11-05 17:08:49.586008
290	Possession of a Class A or B drug with intent to supply	2	2015-11-05 17:08:49.592276	2015-11-05 17:08:49.592276
291	Possession of a Class C drug with intent to supply	3	2015-11-05 17:08:49.598848	2015-11-05 17:08:49.598848
292	Possession of articles for terrorist purposes	2	2015-11-05 17:08:49.605082	2015-11-05 17:08:49.605082
293	Possession of Class A drug	3	2015-11-05 17:08:49.612623	2015-11-05 17:08:49.612623
294	Possession of Class B or C drug	8	2015-11-05 17:08:49.619498	2015-11-05 17:08:49.619498
295	Possession of firearm with criminal intent	2	2015-11-05 17:08:49.626907	2015-11-05 17:08:49.626907
296	Possession of firearm with intent to endanger life	2	2015-11-05 17:08:49.633395	2015-11-05 17:08:49.633395
297	Possession of firearm without certificate	3	2015-11-05 17:08:49.639952	2015-11-05 17:08:49.639952
298	Possession of firearms by person convicted of crime	3	2015-11-05 17:08:49.646402	2015-11-05 17:08:49.646402
299	Possession of offensive weapon	8	2015-11-05 17:08:49.652991	2015-11-05 17:08:49.652991
300	Possession or acquisition of certain prohibited weapons etc.	2	2015-11-05 17:08:49.659285	2015-11-05 17:08:49.659285
301	Possession or acquisition of shotgun without certificate	3	2015-11-05 17:08:49.666379	2015-11-05 17:08:49.666379
302	Practitioner contravening drug supply regulations	2	2015-11-05 17:08:49.674259	2015-11-05 17:08:49.674259
303	Prejudicing a drug trafficking investigation	9	2015-11-05 17:08:49.680658	2015-11-05 17:08:49.680658
304	Presentation of obscene performance	8	2015-11-05 17:08:49.686837	2015-11-05 17:08:49.686837
305	Prison mutiny	2	2015-11-05 17:08:49.693015	2015-11-05 17:08:49.693015
306	Procuration of girl under 21	4	2015-11-05 17:08:49.699151	2015-11-05 17:08:49.699151
307	Procurement of a defective	4	2015-11-05 17:08:49.706638	2015-11-05 17:08:49.706638
308	Procurement of a woman by false pretences	8	2015-11-05 17:08:49.71287	2015-11-05 17:08:49.71287
309	Procurement of intercourse by threats etc.	8	2015-11-05 17:08:49.719418	2015-11-05 17:08:49.719418
310	Procuring others to commit homosexual acts	8	2015-11-05 17:08:49.726244	2015-11-05 17:08:49.726244
311	Producing or supplying a Class A or B drug	2	2015-11-05 17:08:49.732655	2015-11-05 17:08:49.732655
312	Producing or supplying Class C drug	3	2015-11-05 17:08:49.739667	2015-11-05 17:08:49.739667
313	Putting people in fear of violence	8	2015-11-05 17:08:49.74621	2015-11-05 17:08:49.74621
314	Racially aggravated harassment/putting another in fear of violence	8	2015-11-05 17:08:49.753299	2015-11-05 17:08:49.753299
315	Racially-aggravated arson (not endangering life)	2	2015-11-05 17:08:49.759909	2015-11-05 17:08:49.759909
316	Racially-aggravated assault	3	2015-11-05 17:08:49.767043	2015-11-05 17:08:49.767043
317	Racially-aggravated criminal damage	3	2015-11-05 17:08:49.773373	2015-11-05 17:08:49.773373
318	Racially-aggravated public order offence	8	2015-11-05 17:08:49.779912	2015-11-05 17:08:49.779912
319	Rape	10	2015-11-05 17:08:49.786281	2015-11-05 17:08:49.786281
320	Rape of child under 13	10	2015-11-05 17:08:49.795509	2015-11-05 17:08:49.795509
321	Removal of articles from places open to the public	7	2015-11-05 17:08:49.80201	2015-11-05 17:08:49.80201
322	Rescue	3	2015-11-05 17:08:49.808607	2015-11-05 17:08:49.808607
323	Riot	2	2015-11-05 17:08:49.815076	2015-11-05 17:08:49.815076
324	Robbery (other than armed robbery)	3	2015-11-05 17:08:49.821671	2015-11-05 17:08:49.821671
325	Sending prohibited articles by post	8	2015-11-05 17:08:49.828988	2015-11-05 17:08:49.828988
326	Setting spring guns with intent to inflict grievous bodily harm	3	2015-11-05 17:08:49.835451	2015-11-05 17:08:49.835451
327	Sex with adult relative	4	2015-11-05 17:08:49.841933	2015-11-05 17:08:49.841933
328	Sexual activity with a child	10	2015-11-05 17:08:49.848261	2015-11-05 17:08:49.848261
329	Sexual activity with a child family member, with penetration	10	2015-11-05 17:08:49.854589	2015-11-05 17:08:49.854589
330	Sexual activity with a person with a mental disorder	10	2015-11-05 17:08:49.861443	2015-11-05 17:08:49.861443
331	Sexual assault	4	2015-11-05 17:08:49.868583	2015-11-05 17:08:49.868583
332	Sexual assault of child under 13	10	2015-11-05 17:08:49.875245	2015-11-05 17:08:49.875245
333	Sexual intercourse with defective	10	2015-11-05 17:08:49.881911	2015-11-05 17:08:49.881911
334	Sexual intercourse with girl under 13	10	2015-11-05 17:08:49.888093	2015-11-05 17:08:49.888093
335	Sexual intercourse with girl under 16	10	2015-11-05 17:08:49.894347	2015-11-05 17:08:49.894347
336	Sexual intercourse with patients	10	2015-11-05 17:08:49.900388	2015-11-05 17:08:49.900388
337	Sexual penetration of a corpse	4	2015-11-05 17:08:49.906838	2015-11-05 17:08:49.906838
338	Shortening of shotgun or possession of shortened shotgun	3	2015-11-05 17:08:49.913032	2015-11-05 17:08:49.913032
339	Shortening of smooth bore gun	3	2015-11-05 17:08:49.919085	2015-11-05 17:08:49.919085
340	Solicitation for immoral purposes	8	2015-11-05 17:08:49.925376	2015-11-05 17:08:49.925376
341	Soliciting to commit murder	1	2015-11-05 17:08:49.932073	2015-11-05 17:08:49.932073
342	Stirring up racial hatred	3	2015-11-05 17:08:49.938297	2015-11-05 17:08:49.938297
343	Supplying instrument etc. to cause miscarriage	3	2015-11-05 17:08:49.944353	2015-11-05 17:08:49.944353
344	Support or meeting of proscribed organisations	2	2015-11-05 17:08:49.951799	2015-11-05 17:08:49.951799
345	Taking, having etc. indecent photographs of children	10	2015-11-05 17:08:49.957982	2015-11-05 17:08:49.957982
346	Theft	6	2015-11-05 17:08:49.965386	2015-11-05 17:08:49.965386
347	Theft	7	2015-11-05 17:08:49.971887	2015-11-05 17:08:49.971887
348	Theft	11	2015-11-05 17:08:49.978178	2015-11-05 17:08:49.978178
349	Tipping off	2	2015-11-05 17:08:49.984508	2015-11-05 17:08:49.984508
350	Tipping-off in relation to money laundering investigations	3	2015-11-05 17:08:49.99142	2015-11-05 17:08:49.99142
351	Trade description offences (9 offences)	8	2015-11-05 17:08:49.997558	2015-11-05 17:08:49.997558
352	Trafficking into UK for sexual exploitation	10	2015-11-05 17:08:50.003757	2015-11-05 17:08:50.003757
353	Trafficking out of UK for sexual exploitation	10	2015-11-05 17:08:50.010368	2015-11-05 17:08:50.010368
354	Trafficking within UK for sexual exploitation	10	2015-11-05 17:08:50.017205	2015-11-05 17:08:50.017205
355	Trespass with intent to commit sexual offence	4	2015-11-05 17:08:50.026952	2015-11-05 17:08:50.026952
356	Trespassing with a firearm	3	2015-11-05 17:08:50.033558	2015-11-05 17:08:50.033558
357	Undischarged bankrupt being concerned in a company	7	2015-11-05 17:08:50.039938	2015-11-05 17:08:50.039938
358	Uniform of proscribed organisations	2	2015-11-05 17:08:50.046604	2015-11-05 17:08:50.046604
359	Unlawful collection of information for terrorist purposes	2	2015-11-05 17:08:50.070756	2015-11-05 17:08:50.070756
360	Unlawful eviction and harassment of occupier	8	2015-11-05 17:08:50.088826	2015-11-05 17:08:50.088826
361	Unlawful wounding	3	2015-11-05 17:08:50.095514	2015-11-05 17:08:50.095514
362	Use of firearm to resist arrest	2	2015-11-05 17:08:50.102694	2015-11-05 17:08:50.102694
363	Using a copy of a false instrument	6	2015-11-05 17:08:50.109176	2015-11-05 17:08:50.109176
364	Using a copy of a false instrument	7	2015-11-05 17:08:50.115563	2015-11-05 17:08:50.115563
365	Using a copy of a false instrument	11	2015-11-05 17:08:50.123283	2015-11-05 17:08:50.123283
366	Using a false instrument	6	2015-11-05 17:08:50.130826	2015-11-05 17:08:50.130826
367	Using a false instrument	7	2015-11-05 17:08:50.1381	2015-11-05 17:08:50.1381
368	Using a false instrument	11	2015-11-05 17:08:50.144275	2015-11-05 17:08:50.144275
369	Using explosive or corrosives with intent to cause grievous bodily harm	2	2015-11-05 17:08:50.150546	2015-11-05 17:08:50.150546
370	VAT offences	6	2015-11-05 17:08:50.157164	2015-11-05 17:08:50.157164
371	VAT offences	7	2015-11-05 17:08:50.163758	2015-11-05 17:08:50.163758
372	VAT offences	11	2015-11-05 17:08:50.171535	2015-11-05 17:08:50.171535
373	Violent disorder	2	2015-11-05 17:08:50.178236	2015-11-05 17:08:50.178236
374	Voyeurism	4	2015-11-05 17:08:50.185447	2015-11-05 17:08:50.185447
375	Wanton or furious driving	8	2015-11-05 17:08:50.202818	2015-11-05 17:08:50.202818
376	Weapons training	2	2015-11-05 17:08:50.210275	2015-11-05 17:08:50.210275
377	Woman exercising control over prostitute	4	2015-11-05 17:08:50.223133	2015-11-05 17:08:50.223133
378	Wounding or grievous bodily harm with intent to cause grievous bodily harm etc.	2	2015-11-05 17:08:50.230066	2015-11-05 17:08:50.230066
379	Miscellaneous/other	1	2015-11-05 17:08:50.236439	2015-11-05 17:08:50.236439
380	Miscellaneous/other	2	2015-11-05 17:08:50.242864	2015-11-05 17:08:50.242864
381	Miscellaneous/other	3	2015-11-05 17:08:50.249066	2015-11-05 17:08:50.249066
382	Miscellaneous/other	4	2015-11-05 17:08:50.255631	2015-11-05 17:08:50.255631
383	Miscellaneous/other	5	2015-11-05 17:08:50.261846	2015-11-05 17:08:50.261846
384	Miscellaneous/other	6	2015-11-05 17:08:50.268706	2015-11-05 17:08:50.268706
385	Miscellaneous/other	7	2015-11-05 17:08:50.27499	2015-11-05 17:08:50.27499
386	Miscellaneous/other	8	2015-11-05 17:08:50.369337	2015-11-05 17:08:50.369337
387	Miscellaneous/other	9	2015-11-05 17:08:50.376568	2015-11-05 17:08:50.376568
388	Miscellaneous/other	10	2015-11-05 17:08:50.383004	2015-11-05 17:08:50.383004
389	Miscellaneous/other	11	2015-11-05 17:08:50.390204	2015-11-05 17:08:50.390204
252	Obtaining services by dishonesty	6	2015-11-05 17:08:49.310585	2015-11-05 17:08:49.310585
253	Obtaining services by dishonesty	7	2015-11-05 17:08:49.318179	2015-11-05 17:08:49.318179
254	Obtaining services by dishonesty	11	2015-11-05 17:08:49.324632	2015-11-05 17:08:49.324632
390	Counterfeiting notes and coins	6	2016-07-04 12:59:07.072452	2016-07-04 12:59:07.072452
391	Counterfeiting notes and coins	11	2016-07-04 12:59:07.085427	2016-07-04 12:59:07.085427
392	Destruction of registers of births etc.	7	2016-07-04 12:59:07.160752	2016-07-04 12:59:07.160752
393	Destruction of registers of births etc.	11	2016-07-04 12:59:07.169343	2016-07-04 12:59:07.169343
394	Fraudulent evasion: counterfeit notes or coins	6	2016-07-04 12:59:07.440866	2016-07-04 12:59:07.440866
395	Fraudulent evasion: counterfeit notes or coins	11	2016-07-04 12:59:07.453046	2016-07-04 12:59:07.453046
396	Illegal importation: counterfeit notes or coins	6	2016-07-04 12:59:07.538516	2016-07-04 12:59:07.538516
397	Illegal importation: counterfeit notes or coins	11	2016-07-04 12:59:07.55083	2016-07-04 12:59:07.55083
398	Making false entries in copies of registers sent to register	7	2016-07-04 12:59:07.675211	2016-07-04 12:59:07.675211
399	Making false entries in copies of registers sent to register	11	2016-07-04 12:59:07.683445	2016-07-04 12:59:07.683445
400	Making, custody or control of counterfeiting materials etc.	6	2016-07-04 12:59:07.740112	2016-07-04 12:59:07.740112
401	Making, custody or control of counterfeiting materials etc.	11	2016-07-04 12:59:07.752856	2016-07-04 12:59:07.752856
402	Offences involving custody or control of counterfeit notes and coins	6	2016-07-04 12:59:07.904465	2016-07-04 12:59:07.904465
403	Offences involving custody or control of counterfeit notes and coins	11	2016-07-04 12:59:07.91789	2016-07-04 12:59:07.91789
404	Passing counterfeit notes and coins	6	2016-07-04 12:59:07.961912	2016-07-04 12:59:07.961912
405	Passing counterfeit notes and coins	11	2016-07-04 12:59:07.973789	2016-07-04 12:59:07.973789
406	Possession (with intention) of apparatus or material for making false identity documents	7	2016-07-04 12:59:08.034922	2016-07-04 12:59:08.034922
407	Possession (with intention) of apparatus or material for making false identity documents	11	2016-07-04 12:59:08.042305	2016-07-04 12:59:08.042305
408	Possession (with intention) of false identity documents	7	2016-07-04 12:59:08.053989	2016-07-04 12:59:08.053989
409	Possession (with intention) of false identity documents	11	2016-07-04 12:59:08.062125	2016-07-04 12:59:08.062125
410	Possession of false identify documents	7	2016-07-04 12:59:08.073896	2016-07-04 12:59:08.073896
411	Possession of false identify documents	11	2016-07-04 12:59:08.08105	2016-07-04 12:59:08.08105
412	Possession (without reasonable excuse) of false identity documents or apparatus or material for making false identity documents	7	2016-07-04 12:59:08.092829	2016-07-04 12:59:08.092829
413	Possession (without reasonable excuse) of false identity documents or apparatus or material for making false identity documents	11	2016-07-04 12:59:08.100047	2016-07-04 12:59:08.100047
414	Removal of articles from places open to the public	6	2016-07-04 12:59:08.263313	2016-07-04 12:59:08.263313
415	Removal of articles from places open to the public	11	2016-07-04 12:59:08.274802	2016-07-04 12:59:08.274802
416	Undischarged bankrupt being concerned in a company	6	2016-07-04 12:59:08.52003	2016-07-04 12:59:08.52003
417	Undischarged bankrupt being concerned in a company	11	2016-07-04 12:59:08.547465	2016-07-04 12:59:08.547465
\.


--
-- Name: offences_id_seq; Type: SEQUENCE SET; Schema: public; Owner: stephenrichards
--

SELECT pg_catalog.setval('offences_id_seq', 417, true);


--
-- Name: case_types_pkey; Type: CONSTRAINT; Schema: public; Owner: stephenrichards
--

ALTER TABLE ONLY case_types
    ADD CONSTRAINT case_types_pkey PRIMARY KEY (id);


--
-- Name: courts_pkey; Type: CONSTRAINT; Schema: public; Owner: stephenrichards
--

ALTER TABLE ONLY courts
    ADD CONSTRAINT courts_pkey PRIMARY KEY (id);


--
-- Name: disbursement_types_pkey; Type: CONSTRAINT; Schema: public; Owner: stephenrichards
--

ALTER TABLE ONLY disbursement_types
    ADD CONSTRAINT disbursement_types_pkey PRIMARY KEY (id);


--
-- Name: expense_types_pkey; Type: CONSTRAINT; Schema: public; Owner: stephenrichards
--

ALTER TABLE ONLY expense_types
    ADD CONSTRAINT expense_types_pkey PRIMARY KEY (id);


--
-- Name: fee_types_pkey; Type: CONSTRAINT; Schema: public; Owner: stephenrichards
--

ALTER TABLE ONLY fee_types
    ADD CONSTRAINT fee_types_pkey PRIMARY KEY (id);


--
-- Name: offence_classes_pkey; Type: CONSTRAINT; Schema: public; Owner: stephenrichards
--

ALTER TABLE ONLY offence_classes
    ADD CONSTRAINT offence_classes_pkey PRIMARY KEY (id);


--
-- Name: offences_pkey; Type: CONSTRAINT; Schema: public; Owner: stephenrichards
--

ALTER TABLE ONLY offences
    ADD CONSTRAINT offences_pkey PRIMARY KEY (id);


--
-- Name: index_courts_on_code; Type: INDEX; Schema: public; Owner: stephenrichards
--

CREATE INDEX index_courts_on_code ON courts USING btree (code);


--
-- Name: index_courts_on_court_type; Type: INDEX; Schema: public; Owner: stephenrichards
--

CREATE INDEX index_courts_on_court_type ON courts USING btree (court_type);


--
-- Name: index_courts_on_name; Type: INDEX; Schema: public; Owner: stephenrichards
--

CREATE INDEX index_courts_on_name ON courts USING btree (name);


--
-- Name: index_disbursement_types_on_name; Type: INDEX; Schema: public; Owner: stephenrichards
--

CREATE INDEX index_disbursement_types_on_name ON disbursement_types USING btree (name);


--
-- Name: index_expense_types_on_name; Type: INDEX; Schema: public; Owner: stephenrichards
--

CREATE INDEX index_expense_types_on_name ON expense_types USING btree (name);


--
-- Name: index_fee_types_on_code; Type: INDEX; Schema: public; Owner: stephenrichards
--

CREATE INDEX index_fee_types_on_code ON fee_types USING btree (code);


--
-- Name: index_fee_types_on_description; Type: INDEX; Schema: public; Owner: stephenrichards
--

CREATE INDEX index_fee_types_on_description ON fee_types USING btree (description);


--
-- Name: index_offence_classes_on_class_letter; Type: INDEX; Schema: public; Owner: stephenrichards
--

CREATE INDEX index_offence_classes_on_class_letter ON offence_classes USING btree (class_letter);


--
-- Name: index_offence_classes_on_description; Type: INDEX; Schema: public; Owner: stephenrichards
--

CREATE INDEX index_offence_classes_on_description ON offence_classes USING btree (description);


--
-- Name: index_offences_on_offence_class_id; Type: INDEX; Schema: public; Owner: stephenrichards
--

CREATE INDEX index_offences_on_offence_class_id ON offences USING btree (offence_class_id);


--
-- PostgreSQL database dump complete
--

