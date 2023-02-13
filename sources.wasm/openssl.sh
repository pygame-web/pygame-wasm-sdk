#!/bin/bash

. ${CONFIG:-config}

export OPENSSL="openssl-1.1.1s"
export URL_OPENSSL=${URL_OPENSSL:-"URL https://ftp.openssl.org/source/$OPENSSL.tar.gz"}
export HASH_OPENSSL="URL_HASH SHA256=c5ac01e760ee6ff0dab61d6b2bbd30146724d063eb322180c6f18a6f74e4b6aa"

. scripts/emsdk-fetch.sh

if [ -f openssl.patched ]
then
    echo "
        already patched for $PREFIX
    "
else
    wget -c $URL_OPENSSL
    tar xvfz $OPENSSL.tar.gz
    pushd $OPENSSL
    patch -p1 <<END
--- openssl-1.1.1n/Configurations/10-main.conf	2022-03-15 14:37:47.000000000 +0000
+++ openssl-1.1.1n-fixed/Configurations/10-main.conf	2022-04-05 10:48:27.348576840 +0000
@@ -657,7 +657,8 @@
     },
     "linux-generic64" => {
         inherit_from     => [ "linux-generic32" ],
-        bn_ops           => "SIXTY_FOUR_BIT_LONG RC4_CHAR",
+        bn_ops           => "SIXTY_FOUR_BIT RC4_CHAR",
+        lib_cppflags     => add("-DBN_DIV2W"),
     },

     "linux-ppc" => {
diff -urN openssl-1.1.1n/crypto/rand/rand_unix.c openssl-1.1.1n-fixed/crypto/rand/rand_unix.c
--- openssl-1.1.1n/crypto/rand/rand_unix.c	2022-04-05 10:54:21.980130409 +0000
+++ openssl-1.1.1n-fixed/crypto/rand/rand_unix.c	2022-04-05 09:27:47.960526811 +0000
@@ -369,7 +369,7 @@
      * Note: Sometimes getentropy() can be provided but not implemented
      * internally. So we need to check errno for ENOSYS
      */
-#  if defined(__GNUC__) && __GNUC__>=2 && defined(__ELF__) && !defined(__hpux)
+#  if defined(__EMSCRIPTEN__)
     extern int getentropy(void *buffer, size_t length) __attribute__((weak));

     if (getentropy != NULL) {
END

    touch ../openssl.patched
    popd
fi

if [ -f $PREFIX/lib/libssl.a ]
then
    echo "
        already built in $PREFIX/lib/libssl.a
    "
else
    pushd $OPENSSL
    emconfigure ./Configure linux-generic64 \
      no-asm \
      no-engine \
      no-hw \
      no-weak-ssl-ciphers \
      no-dtls \
      no-shared \
      no-dso \
      -DPEDANTIC \
      --prefix="$PREFIX" --openssldir=/home/web_user

    sed -i 's|^CROSS_COMPILE.*$|CROSS_COMPILE=|g' Makefile
    emmake make build_generated libssl.a libcrypto.a
    cp -r include/openssl "$PREFIX/include"
    cp libcrypto.a libssl.a "$PREFIX/lib"
    popd
fi
