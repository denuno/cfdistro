package cfmlengcrypt;

import railo.runtime.crypt.BlowfishEasy;

/**
 * Encrypts CFDSN passwords
 */
public class RailoEncrypt {

	public static void main(String[] args) {
		encrypt(args[0]);
	}

	public static void encrypt(String plaintext) {
		System.out.print(new BlowfishEasy("tpwisgh").encryptString(plaintext));
	}
}