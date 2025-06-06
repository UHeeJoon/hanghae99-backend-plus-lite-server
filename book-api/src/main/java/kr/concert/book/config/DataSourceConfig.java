package kr.concert.book.config;

import com.zaxxer.hikari.HikariDataSource;
import org.springframework.boot.autoconfigure.jdbc.DataSourceProperties;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.datasource.LazyConnectionDataSourceProxy;

import javax.sql.DataSource;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * datasource
 *
 * @author :Uheejoon
 * @date :2025-06-04 오후 8:37
 */
@Configuration
public class DataSourceConfig {
    @Bean
    @ConfigurationProperties(prefix = "spring.datasource.primary")
    public DataSourceProperties primaryDataSourceProperties(){
        return new DataSourceProperties();
    }

    @Bean
    public DataSource primaryDataSource() {
        DataSourceProperties property = primaryDataSourceProperties();
        HikariDataSource dataSource = DataSourceBuilder.create()
          .type(HikariDataSource.class)
          .driverClassName(property.getDriverClassName())
          //.url(property.getUrl())
          .username(property.getUsername())
          .password(property.getPassword())
          .build();
        dataSource.setJdbcUrl(property.getUrl());
        return dataSource;
    }

    @Bean
    @ConfigurationProperties(prefix = "spring.datasource.replicas")
    public Map<String, DataSourceProperties> replicaDataSourceProperties(){
        return new HashMap<>();
    }

    @Bean
    public Map<String, DataSource> replicaDataSource() {
        Map<String, DataSourceProperties> dataSourceProperties = replicaDataSourceProperties();
        Map<String, DataSource> slaveDataSources = new HashMap<>();
        for(String key : dataSourceProperties.keySet()){
            DataSourceProperties properties = dataSourceProperties.get(key);
            System.out.println(properties.getUrl());
            HikariDataSource dataSource = DataSourceBuilder.create()
              .type(HikariDataSource.class)
              .driverClassName(properties.getDriverClassName())
              //.url(properties.getUrl())
              .username(properties.getUsername())
              .password(properties.getPassword())
              .build();
            dataSource.setJdbcUrl(properties.getUrl());
            slaveDataSources.put(key, dataSource);
        }
        return slaveDataSources;
    }

    @Bean
    public DataSource routingDataSource( DataSource primaryDataSource, Map<String, DataSource> replicaDataSources) {
        Map<Object, Object> dataSources = new HashMap<>(replicaDataSources);
        dataSources.put("source", primaryDataSource);

        List<String> replicaList = new ArrayList<>(replicaDataSources.keySet());

        RoutingDataSource routingDataSource = new RoutingDataSource(replicaList);
        routingDataSource.setDefaultTargetDataSource(primaryDataSource);
        routingDataSource.setTargetDataSources(dataSources);

        return routingDataSource;
    }

    @Primary
    @Bean
    public DataSource dataSource() {
        return new LazyConnectionDataSourceProxy(routingDataSource(primaryDataSource(), replicaDataSource()));
    }
}
