package dev.thiagofonseca.cari.mono.user.repository;

import dev.thiagofonseca.cari.mono.user.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    User findByUsername(String username);
}
