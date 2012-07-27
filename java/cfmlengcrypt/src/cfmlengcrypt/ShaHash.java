package cfmlengcrypt;

import railo.runtime.crypt.SHA1;

/**
 * Encrypts CFDSN passwords
 */
public class ShaHash {

	public static void main(String[] args) {
		encrypt(args[0]);
	}

	public static void encrypt(String plaintext) {
		SHA1 sha = new SHA1();
		sha.update(plaintext);
		sha.finalize();
		byte[] digest = sha.getDigest(); 
		System.out.print(sha.toString());
	}
}