```mermaid
erDiagram

    User {
        UUID id PK "유저 고유 ID"
        string email "이메일 (로그인 ID)"
        string name "사용자 이름"
        int balance "잔액 (원 단위)"
        datetime created_at "가입일"
    }

    Concert {
        UUID id PK "콘서트 ID"
        string title "콘서트 제목"
        string description "설명"
        datetime start_time "콘서트 시작 시각"
        datetime end_time "콘서트 종료 시각"
        datetime created_at
    }

    ConcertDate {
        UUID id PK "예약 가능한 날짜 ID"
        UUID concert_id FK "콘서트 참조"
        date concert_date "날짜 (YYYY-MM-DD)"
        datetime created_at
    }

    Seat {
        UUID id PK "좌석 ID"
        UUID concert_date_id FK "해당 날짜 참조"
        int seat_number "1~50 좌석 번호"
        enum status "AVAILABLE | HELD | RESERVED"
        UUID held_by FK "임시 점유 유저 ID"
        datetime hold_expire_at "임시 배정 만료 시간"
    }

    Reservation {
        UUID id PK "예약 ID"
        UUID user_id FK "예약자"
        UUID seat_id FK "예약 좌석"
        enum status "HOLD | CONFIRMED"
        datetime created_at "예약 시각"
        datetime confirmed_at "결제 완료 시각"
    }

    Payment {
        UUID id PK "결제 ID"
        UUID user_id FK "결제한 유저"
        UUID reservation_id FK "예약 참조"
        int amount "결제 금액"
        enum status "SUCCESS | FAILED"
        string reason "실패 사유 (nullable)"
        datetime paid_at "결제 시각"
    }

    ChargeHistory {
        UUID id PK "충전 기록 ID"
        UUID user_id FK "충전 유저"
        int amount "충전 금액"
        enum status "SUCCESS | FAILED"
        string reason "실패 사유 (nullable)"
        datetime charged_at "충전 시각"
    }

    UsageHistory {
        UUID id PK "사용 기록 ID"
        UUID user_id FK "사용 유저"
        int amount "사용된 금액"
        enum action_type "RESERVATION | CANCELLATION | OTHER"
        enum status "SUCCESS | FAILED"
        string reason "실패 사유 (nullable)"
        datetime used_at "사용 시각"
    }

    QueueToken {
        UUID token PK "대기열 토큰 ID (UUID)"
        UUID user_id FK "사용자"
        int queue_position "대기열 순서"
        boolean is_admitted "입장 허용 여부"
        datetime issued_at
        datetime expired_at
    }

    QueueEntryHistory {
        UUID id PK "대기열 이력 ID"
        UUID user_id FK
        UUID token 
        datetime entered_at 
        datetime admitted_at nullable
        datetime exited_at nullable
        boolean was_admitted
        int duration_seconds
    }

    SeatStatusHistory {
        UUID id PK "좌석 상태 변경 이력 ID"
        UUID seat_id FK
        enum from_status "AVAILABLE | HELD | RESERVED"
        enum to_status "AVAILABLE | HELD | RESERVED"
        UUID changed_by_user_id "nullable"
        string reason "nullable"
        datetime changed_at
    }

    User ||--o{ QueueToken : has
    User ||--o{ Reservation : makes
    User ||--o{ Payment : pays
    User ||--o{ ChargeHistory : charges
    User ||--o{ UsageHistory : uses
    User ||--o{ QueueEntryHistory : queues
    QueueToken }o--|| User : belongs_to
    Concert ||--o{ ConcertDate : has
    ConcertDate ||--o{ Seat : has
    Seat ||--|| ConcertDate : belongs_to
    Seat ||--o{ Reservation : reserved_by
    Reservation ||--|| Seat : for_seat
    Reservation ||--|| User : by_user
    Payment ||--|| Reservation : for
    QueueEntryHistory ||--|| User : by_user
    SeatStatusHistory ||--|| Seat : for_seat
```


| 테이블                      | 용도                  |
| ------------------------ | ------------------- |
| `User`                   | 사용자 식별 및 잔액 관리      |
| `Concert`, `ConcertDate` | 콘서트 및 날짜 단위 구성      |
| `Seat`                   | 날짜별 좌석 및 상태 관리      |
| `Reservation`            | 좌석 예약 상태 기록         |
| `Payment`                | 결제 결과 및 실패 사유 추적    |
| `ChargeHistory`          | 충전 요청 내역 저장         |
| `UsageHistory`           | 잔액 사용 흐름 기록         |
| `QueueToken`             | 유저의 현재 대기열 토큰       |
| `QueueEntryHistory`      | 대기열 진입\~입장 전체 흐름 기록 |
| `SeatStatusHistory`      | 좌석 상태 전이 이력 기록      |
