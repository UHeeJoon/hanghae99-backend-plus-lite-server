package kr.concert.book.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.datasource.lookup.AbstractRoutingDataSource;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * db routing
 *
 * @author :Uheejoon
 * @date :2025-06-04 오후 9:48
 */
@Slf4j
public class RoutingDataSource extends AbstractRoutingDataSource {

    private final List<String> routingReplicas;
    private final AtomicInteger index;

    public RoutingDataSource(List<String> routingReplicas) {
        this.routingReplicas = routingReplicas;
        index = new AtomicInteger(0);
    }

    @Override
    protected Object determineCurrentLookupKey() {
        boolean isReadOnly = TransactionSynchronizationManager.isCurrentTransactionReadOnly();
        if (isReadOnly) {
            log.info("read replica");
            return routingReplicas.get(index.getAndIncrement() % routingReplicas.size());
        } else {
            log.info("write primary");
            return "source";
        }
    }

}