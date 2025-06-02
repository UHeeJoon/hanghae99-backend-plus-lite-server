![시스템 아키텍처](./img/architecture.png)
---
1. 사용자의 처리를 nginx가 로드 밸런싱 및 ssl 설정
2. 콘서트 예약 서버로 바로 가는 것이 아닌 대기열 서버로 감
3. 대기열의 queue를 redis를 사용하여 구현
4. 대기열 통과하면 예약 서버로 이동
5. 예약 서버에서 발행된 이벤트를 kafka로 처리
6. 모니터링은 grafana와 prometheus로 진행