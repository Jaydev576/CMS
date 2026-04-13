/**
 * One-time utility to generate password hashes for SQL seed data.
 * 
 * Compile & run:
 * javac PasswordHash.java HashExistingPasswords.java
 * java HashExistingPasswords
 * 
 * Copy the output hashes into the INSERT statements in
 * full_dump_final_fixed.sql,
 * then you can delete this file.
 */
public class HashExistingPasswords {
    public static void main(String[] args) {
        String[][] users = {
                { "admin", "admin" },
                { "democreator", "democreator" },
                { "demoviewer", "demoviewer" }
        };

        System.out.println("=== Password Hashes for SQL Seed Data ===\n");
        for (String[] user : users) {
            String hash = PasswordHash.hashPassword(user[1]);
            System.out.println("Username:  " + user[0]);
            System.out.println("Password:  " + user[1]);
            System.out.println("Hash:      " + hash);

            // Verify it works
            boolean ok = PasswordHash.verifyPassword(user[1], hash);
            System.out.println("Verified:  " + ok);
            System.out.println();
        }
    }
}
