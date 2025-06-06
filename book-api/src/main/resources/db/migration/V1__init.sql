-- 사용자 테이블
CREATE TABLE USERS
(
    id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '유저 ID',
    user_token VARCHAR(255) NOT NULL UNIQUE COMMENT '유저 식별 랜덤 문자',
    email      VARCHAR(50)  NOT NULL UNIQUE COMMENT '이메일 (로그인 ID)',
    name       VARCHAR(30)  NOT NULL COMMENT '사용자 이름',
    balance    INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '잔액 (원 단위)',
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '가입일'
) CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;


-- 콘서트 테이블
CREATE TABLE CONCERTS
(
    id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '콘서트 ID',
    title       VARCHAR(255) NOT NULL COMMENT '콘서트 제목',
    description VARCHAR(2500) COMMENT '콘서트 상세 설명',
    address     VARCHAR(500) NOT NULL COMMENT '콘서트 장소',
    start_time  DATETIME     NOT NULL COMMENT '콘서트 시작 시각',
    end_time    DATETIME     NOT NULL COMMENT '콘서트 종료 시각',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 예약 가능한 날짜 테이블
CREATE TABLE CONCERT_DATE
(
    id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '예약 가능한 날짜 ID',
    concert_id   BIGINT UNSIGNED NOT NULL COMMENT '콘서트 참조',
    concert_date DATE            NOT NULL COMMENT '날짜 (YYYY-MM-DD)',
    created_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (concert_id) REFERENCES CONCERTS (id) ON DELETE CASCADE
) CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_concert_date_concert_date ON CONCERT_DATE (concert_date);
CREATE INDEX idx_concert_date_concert_id ON CONCERT_DATE (concert_id);

-- 좌석 테이블
CREATE TABLE SEATS
(
    id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '좌석 ID',
    concert_date_id BIGINT UNSIGNED                        NOT NULL COMMENT '해당 날짜 참조',
    seat_number     TINYINT UNSIGNED                       NOT NULL COMMENT '1~50 좌석 번호',
    price           INT UNSIGNED                           NOT NULL COMMENT '좌석 가격',
    status          ENUM ('AVAILABLE', 'HOLD', 'RESERVED') NOT NULL DEFAULT 'AVAILABLE' COMMENT '좌석 상태',
    hold_expire_at  DATETIME COMMENT '임시 배정 만료 시간',
    FOREIGN KEY (concert_date_id) REFERENCES CONCERT_DATE (id) ON DELETE CASCADE,
    UNIQUE (concert_date_id, seat_number)
) CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_seat_status ON SEATS (status);
CREATE INDEX idx_seat_concert_date_id ON SEATS (concert_date_id);


-- 예약 테이블
CREATE TABLE RESERVATIONS
(
    id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '예약 ID',
    user_id      BIGINT UNSIGNED           NOT NULL COMMENT '예약자',
    seat_id      BIGINT UNSIGNED           NOT NULL COMMENT '예약 좌석',
    status       ENUM ('HOLD', 'RESERVED') NOT NULL COMMENT '예약 상태',
    created_at   DATETIME                  NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '예약 시각',
    confirmed_at DATETIME COMMENT '결제 완료 시각',
    FOREIGN KEY (user_id) REFERENCES USERS (id) ON DELETE CASCADE,
    FOREIGN KEY (seat_id) REFERENCES SEATS (id) ON DELETE CASCADE,
    UNIQUE (seat_id)
) CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_reservation_status ON RESERVATIONS (status);
CREATE INDEX idx_reservation_user_id ON RESERVATIONS (user_id);

-- 결제 테이블
CREATE TABLE PAYMENTS
(
    id             BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '결제 ID',
    user_id        BIGINT UNSIGNED            NOT NULL COMMENT '결제한 유저',
    reservation_id BIGINT UNSIGNED            NOT NULL COMMENT '예약 참조',
    payment_token  VARCHAR(255)               NOT NULL UNIQUE COMMENT '결제 정보 식별 랜덤 문자',
    amount         INT UNSIGNED               NOT NULL COMMENT '결제 금액',
    status         ENUM ('SUCCESS', 'FAILED') NOT NULL COMMENT '결제 상태',
    reason         VARCHAR(255) COMMENT '실패 사유',
    paid_at        DATETIME                   NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '결제 시각',
    FOREIGN KEY (user_id) REFERENCES USERS (id) ON DELETE CASCADE,
    FOREIGN KEY (reservation_id) REFERENCES RESERVATIONS (id) ON DELETE CASCADE
) CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_payment_user_id ON PAYMENTS (user_id);
CREATE INDEX idx_payment_reservation_id ON PAYMENTS (reservation_id);


-- 포인트 충전 내역 테이블
CREATE TABLE POINT_CHARGE_HISTORIES
(
    id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '충전 기록 ID',
    user_id    BIGINT UNSIGNED            NOT NULL COMMENT '충전 유저',
    amount     INT                        NOT NULL COMMENT '충전 금액',
    status     ENUM ('SUCCESS', 'FAILED') NOT NULL COMMENT '충전 상태',
    reason     VARCHAR(255) COMMENT '실패 사유',
    charged_at DATETIME                   NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '충전 시각',
    FOREIGN KEY (user_id) REFERENCES USERS (id) ON DELETE CASCADE
) CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_point_charge_user_id ON POINT_CHARGE_HISTORIES (user_id);

-- 포인트 사용 내역 테이블
CREATE TABLE POINT_USAGE_HISTORIES
(
    id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '사용 기록 ID',
    user_id     BIGINT UNSIGNED                      NOT NULL COMMENT '사용 유저',
    amount      INT UNSIGNED                         NOT NULL COMMENT '사용된 금액',
    action_type ENUM ('RESERVATION', 'CANCELLATION') NOT NULL COMMENT '사용 유형',
    status      ENUM ('SUCCESS', 'FAILED')           NOT NULL COMMENT '사용 상태',
    reason      VARCHAR(255) COMMENT '실패 사유',
    used_at     DATETIME                             NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '사용 시각',
    FOREIGN KEY (user_id) REFERENCES USERS (id) ON DELETE CASCADE
) CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_point_usage_user_id ON POINT_USAGE_HISTORIES (user_id);