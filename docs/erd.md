```mermaid
erDiagram
    User {
        bigint id PK "유저 ID"
        string user_token "유저 식별 랜덤 문자"
        string email "이메일 (로그인 ID)"
        string name "사용자 이름"
        int balance "잔액 (원 단위)"
        datetime created_at "가입일"
    }
    Concert {
        bigint id PK "콘서트 ID"
        string title "콘서트 제목"
        string description "설명"
        string address "콘서트 장소"
        datetime start_time "콘서트 시작 시각"
        datetime end_time "콘서트 종료 시각"
        datetime created_at
        datetime updated_at
    }
    ConcertDate {
        bigint id PK "예약 가능한 날짜 ID"
        bigint concert_id FK "콘서트 참조"
        date concert_date "날짜 (YYYY-MM-DD)"
        datetime created_at
    }
    Seat {
        bigint id PK "좌석 ID"
        bigint concert_date_id FK "해당 날짜 참조"
        int seat_number "1~50 좌석 번호"
        int price "좌석 가격"
        enum status "AVAILABLE | HOLD | RESERVED"
        datetime hold_expire_at "임시 배정 만료 시간"
    }
    Reservation {
        bigint id PK "예약 ID"
        bigint user_id FK "예약자"
        bigint seat_id FK "예약 좌석"
        enum status "HOLD | RESERVED"
        datetime created_at "예약 시각"
        datetime confirmed_at "결제 완료 시각"
        datetime created_at
    }
    Payment {
        bigint id PK "결제 ID"
        bigint user_id FK "결제한 유저"
        bigint reservation_id FK "예약 참조"
        string payment_token "결제 정보 식별 랜덤 문자"
        int amount "결제 금액"
        enum status "SUCCESS | FAILED"
        string reason "실패 사유 (nullable)"
        datetime paid_at "결제 시각"
    }
    PointChargeHistory {
        bigint id PK "충전 기록 ID"
        bigint user_id FK "충전 유저"
        int amount "충전 금액"
        enum status "SUCCESS | FAILED"
        string reason "실패 사유 (nullable)"
        datetime charged_at "충전 시각"
    }
    PointUsageHistory {
        bigint id PK "사용 기록 ID"
        bigint user_id FK "사용 유저"
        int amount "사용된 금액"
        enum action_type "RESERVATION | CANCELLATION"
        enum status "SUCCESS | FAILED"
        string reason "실패 사유 (nullable)"
        datetime used_at "사용 시각"
    }
    User ||--o{ Reservation: makes
    User ||--o{ Payment: pays
    User ||--o{ PointChargeHistory: charges
    User ||--o{ PointUsageHistory: uses
    Concert ||--o{ ConcertDate: has
    ConcertDate ||--o{ Seat: has
    Seat ||--|| ConcertDate: belongs_to
    Seat ||--o{ Reservation: reserved_by
    Reservation ||--|| Seat: for_seat
    Reservation ||--|| User: by_user
    Payment ||--|| Reservation: for


```

| 테이블                      | 용도                |
|--------------------------|-------------------|
| `User`                   | 사용자 식별 및 잔액 관리    |
| `Concert`, `ConcertDate` | 콘서트 -< 해당 콘서트 날짜들 |
| `Seat`                   | 날짜별 좌석 및 상태 관리    |
| `Reservation`            | 좌석 예약 상태 기록       |
| `Payment`                | 결제 결과             |
| `PointChargeHistory`     | 충전 요청 내역          |
| `PointUsageHistory`      | 잔액 사용 흐름          |
