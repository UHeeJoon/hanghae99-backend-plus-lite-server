# 콘서트 예약 시스템 API 명세서

---

## 1. 유저 토큰 발급 API
### POST /queue/token
> 대기열에 진입하고 토큰을 발급받습니다.

#### 요청
```json
{
  "userId": "uuid"
}
```

#### 응답
```json
{
  "token": "jwt-string",
  "queuePosition": 12,
  "estimatedWaitTime": 180
}
```

---

## 2. 예약 가능 날짜 조회 API
### GET /concert/dates

#### 응답
```json
[
  "2025-06-01",
  "2025-06-02"
]
```

---

## 3. 좌석 목록 조회 API
### GET /concert/seats?date=2025-06-01

#### 응답
```json
[
  { "seatNumber": 1, "status": "AVAILABLE" },
  { "seatNumber": 2, "status": "HELD", "holdExpireAt": "2025-06-01T14:03:00" },
  { "seatNumber": 3, "status": "RESERVED" }
]
```

---

## 4. 좌석 예약 요청 API
### POST /concert/reserve

#### 요청
```json
{
  "token": "jwt-string",
  "date": "2025-06-01",
  "seatNumber": 10
}
```

#### 응답
```json
{
  "status": "HELD",
  "holdExpireAt": "2025-06-01T14:10:00"
}
```

---

## 5. 잔액 충전 API
### POST /balance/charge

#### 요청
```json
{
  "userId": "uuid",
  "amount": 10000
}
```

#### 응답
```json
{
  "balance": 15000
}
```

---

## 6. 잔액 조회 API
### GET /balance?userId=uuid

#### 응답
```json
{
  "balance": 15000
}
```

---

## 7. 결제 API
### POST /concert/payment

#### 요청
```json
{
  "token": "jwt-string",
  "date": "2025-06-01",
  "seatNumber": 10
}
```

#### 응답 (성공)
```json
{
  "status": "PAID",
  "remainingBalance": 5000
}
```

#### 응답 (잔액 부족)
```json
{
  "status": "FAILED",
  "reason": "INSUFFICIENT_FUNDS"
}
```

#### 응답 (임시 배정 없음)
```json
{
  "status": "FAILED",
  "reason": "HOLD_EXPIRED"
}
```

---