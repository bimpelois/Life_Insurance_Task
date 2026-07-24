CREATE DATABASE life_insurance;
-- USE life_insurance;

CREATE TABLE policyholders (
    policyholder_id   INT AUTO_INCREMENT PRIMARY KEY,
    full_name         VARCHAR(20) NOT NULL,
    date_of_birth     DATE NOT NULL,
    phone_number      VARCHAR(15)  NOT NULL,
    email             VARCHAR(40) NOT NULL UNIQUE
);

INSERT INTO policyholders (full_name, date_of_birth, phone, email) VALUES
('Amaka Obi',        '1988-04-12', '08031112222', 'amakaobi987@gmail.com'),
('Tunde Bakare',     '1975-11-02', '08032223333', 'tundebakare893@gmail.com'),
('Ngozi Eze',        '1990-07-19', '08033334444', 'ngozieze098@gmail.com'),
('Chike Okafor',     '1982-01-30', '08034445555', 'chike.okafor234@gmail.com'),
('Bimpe Adewale',    '1995-09-05', '08035556666', 'bimpeadewale546@gmail.com'),
('Segun Alabi',      '1979-03-14', '08036667777', 'segun_alabi897@gmail.com');

CREATE TABLE agents (
    agent_id         INT AUTO_INCREMENT PRIMARY KEY,
    full_name        VARCHAR(20) NOT NULL,
    phone_number     VARCHAR(20)  NOT NULL,
    email            VARCHAR(40) NOT NULL UNIQUE,
    agent_type       ENUM('permanent', 'broker') NOT NULL,
    specialisation   ENUM('Life', 'Auto', 'Home') NULL,

    -- Only permanent agents may have a specialisation;
    -- brokers must have NULL here.
    CONSTRAINT chk_agent_specialisation CHECK (
        (agent_type = 'permanent' AND specialisation IS NOT NULL)
        OR
        (agent_type = 'broker' AND specialisation IS NULL)
    )
);

INSERT INTO agents (full_name, phone, email, agent_type, specialisation) VALUES
('Femi Adeyemi',   '08111112222', 'femiadeyemi66@gmail.com',   'permanent', 'Life'),
('Grace Nweke',    '08111113333', 'gracenweke892@gmail.com',    'permanent', 'Auto'),
('Ibrahim Musa',   '08111114444', 'ibrahimmusa456@gmail.com',   'permanent', 'Home'),
('Chidera Obinna', '08111115555', 'chideraobinna123@gmail.com',  'broker',    NULL),
('Peter Coker',    '08111116666', 'petercoker765@gmail.com',     'broker',    NULL); 

CREATE TABLE policy_types (
    policy_type_id    INT AUTO_INCREMENT PRIMARY KEY,
    full_name              VARCHAR(20)  NOT NULL UNIQUE,
    description       VARCHAR(40) NOT NULL,
    base_premium_rate DECIMAL(10,2) NOT NULL
);

INSERT INTO policy_types (name, description, base_premium_rate) VALUES
('Life', 'Provides a payout to beneficiaries on death of the policyholder', 5000.00),
('Auto', 'Covers damage/liability for the policyholder''s vehicle',         3500.00),
('Home', 'Covers damage/loss to the policyholder''s home and contents',     4200.00);

CREATE TABLE policies (
    policy_id        INT AUTO_INCREMENT PRIMARY KEY,
    policy_number    VARCHAR(20) NOT NULL UNIQUE,
    policyholder_id  INT NOT NULL,
    policy_type_id   INT NOT NULL,
    agent_id         INT NOT NULL,
    start_date       DATE NOT NULL,
    end_date         DATE NOT NULL,
    premium_amount   DECIMAL(10,2) NOT NULL,
    status           ENUM('active', 'expired', 'cancelled') NOT NULL DEFAULT 'active',

    CONSTRAINT fk_policies_policyholder
        FOREIGN KEY (policyholder_id) REFERENCES policyholders(policyholder_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_policies_policy_type
        FOREIGN KEY (policy_type_id) REFERENCES policy_types(policy_type_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_policies_agent
        FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_policy_dates CHECK (end_date > start_date)
);

INSERT INTO policies (policy_number, policyholder_id, policy_type_id, agent_id, start_date, end_date, premium_amount, status) VALUES
('POL-0001', 1, 1, 1, '2024-01-01', '2029-01-01', 5200.00, 'active'),   -- Amaka: Life
('POL-0002', 1, 2, 4, '2024-03-15', '2025-03-15', 3600.00, 'active'),   -- Amaka: Auto (2nd policy)
('POL-0003', 2, 2, 2, '2023-06-01', '2024-06-01', 3400.00, 'expired'),  -- Tunde: Auto
('POL-0004', 3, 3, 3, '2024-02-10', '2025-02-10', 4300.00, 'active'),   -- Ngozi: Home
('POL-0005', 4, 1, 1, '2022-05-01', '2023-05-01', 5100.00, 'cancelled'),-- Chike: Life
('POL-0006', 4, 3, 4, '2024-07-01', '2025-07-01', 4400.00, 'active'),   -- Chike: Home (2nd policy)
('POL-0007', 5, 2, 2, '2024-04-01', '2025-04-01', 3550.00, 'active');   -- Bimpe: Auto

CREATE TABLE claims (
    claim_id         INT AUTO_INCREMENT PRIMARY KEY,
    policy_id        INT NOT NULL,
    date_filed       DATE NOT NULL,
    description      VARCHAR(40) NOT NULL,
    amount_claimed   DECIMAL(10,2) NOT NULL,
    amount_approved  DECIMAL(10,2) NULL,   -- NULL while still 'pending'
    status           ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',

    CONSTRAINT fk_claims_policy
        FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_claim_amounts CHECK (
        amount_approved IS NULL OR amount_approved <= amount_claimed
    )
);

INSERT INTO claims (policy_id, date_filed, description, amount_claimed, amount_approved, status) VALUES
(2, '2024-05-01', 'Minor collision damage',        1200.00,  900.00, 'approved'),
(2, '2024-08-20', 'Windscreen replacement',          350.00,  350.00, 'approved'),
(3, '2023-09-10', 'Fender bender repair',            800.00,     NULL,'pending'),
(4, '2024-06-15', 'Burst pipe water damage',        2500.00, 2000.00, 'approved'),
(4, '2024-11-02', 'Attempted burglary claim',       1500.00,     NULL,'rejected'),
(6, '2024-09-05', 'Storm roof damage',               900.00,  900.00, 'approved'),
(1, '2024-12-01', 'Death benefit claim (test data)', 50000.00,   NULL,'pending'),
(7, '2024-07-20', 'Windscreen crack',                 400.00,     NULL,'rejected');

CREATE TABLE payments (
    payment_id     INT AUTO_INCREMENT PRIMARY KEY,
    policy_id      INT NOT NULL,
    due_date       DATE NOT NULL,
    amount         DECIMAL(10,2) NOT NULL,
    date_paid      DATE NULL,              
    status         ENUM('paid', 'unpaid', 'overdue') NOT NULL DEFAULT 'unpaid',

    CONSTRAINT fk_payments_policy
        FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
        ON DELETE RESTRICT
);

INSERT INTO payments (policy_id, due_date, amount, date_paid, status) VALUES
(1, '2024-01-01', 5200.00, '2024-01-01', 'paid'),
(2, '2024-03-15',  300.00, '2024-03-15', 'paid'),
(2, '2024-04-15',  300.00, NULL,          'overdue'),  
(3, '2023-06-01', 3400.00, '2023-06-01', 'paid'),
(4, '2024-02-10',  358.00, '2024-02-10', 'paid'),
(4, '2024-03-10',  358.00, NULL,          'overdue'),   
(6, '2024-07-01',  366.00, '2024-07-01', 'paid'),
(7, '2024-04-01',  296.00, NULL,          'unpaid'); 

CREATE TABLE beneficiaries (
    beneficiary_id     INT AUTO_INCREMENT PRIMARY KEY,
    policy_id          INT NOT NULL,
    full_name          VARCHAR(40) NOT NULL,
    relationship       VARCHAR(50) NOT NULL,
    percentage_share   DECIMAL(5,2) NOT NULL,

    CONSTRAINT fk_beneficiaries_policy
        FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
        ON DELETE CASCADE,  

    CONSTRAINT chk_beneficiary_share CHECK (
        percentage_share > 0 AND percentage_share <= 100
    )
);

INSERT INTO beneficiaries (policy_id, full_name, relationship, percentage_share) VALUES
(1, 'Chinwe Obi',   'Spouse', 60.00),
(1, 'David Obi',    'Son',    40.00);


