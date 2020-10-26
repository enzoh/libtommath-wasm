# File       : Makefile
# Copyright  : Enzo Haussecker
# License    : Apache 2.0 with LLVM Exception
# Maintainer : Enzo Haussecker <enzo@dfinity.org>
# Stability  : Experimental

SYSROOT ?= /opt/wasi-libc/sysroot
WASM_CC ?= clang-10
WASM_LD ?= wasm-ld-10

SOURCE_DIR = libtommath
TARGET_DIR = build

VERSION = $(shell git -C $(SOURCE_DIR) describe)
RELEASE = libtommath-wasm-$(VERSION)

TARGET_OBJECTS = $(TARGET_DIR)/objects
TARGET_RELEASE = $(TARGET_DIR)/$(RELEASE)
TARGET_TARBALL = $(TARGET_RELEASE).tar.gz

SOURCE_FILES = \
	bn_cutoffs \
	bn_mp_2expt \
	bn_mp_abs \
	bn_mp_add \
	bn_mp_add_d \
	bn_mp_addmod \
	bn_mp_and \
	bn_mp_clamp \
	bn_mp_clear \
	bn_mp_clear_multi \
	bn_mp_cmp \
	bn_mp_cmp_d \
	bn_mp_cmp_mag \
	bn_mp_cnt_lsb \
	bn_mp_complement \
	bn_mp_copy \
	bn_mp_count_bits \
	bn_mp_decr \
	bn_mp_div_2 \
	bn_mp_div_2d \
	bn_mp_div_3 \
	bn_mp_div \
	bn_mp_div_d \
	bn_mp_dr_is_modulus \
	bn_mp_dr_reduce \
	bn_mp_dr_setup \
	bn_mp_error_to_string \
	bn_mp_exch \
	bn_mp_exptmod \
	bn_mp_expt_u32 \
	bn_mp_exteuclid \
	bn_mp_fread \
	bn_mp_from_sbin \
	bn_mp_from_ubin \
	bn_mp_fwrite \
	bn_mp_gcd \
	bn_mp_get_double \
	bn_mp_get_i32 \
	bn_mp_get_i64 \
	bn_mp_get_l \
	bn_mp_get_ll \
	bn_mp_get_mag_u32 \
	bn_mp_get_mag_u64 \
	bn_mp_get_mag_ul \
	bn_mp_get_mag_ull \
	bn_mp_grow \
	bn_mp_incr \
	bn_mp_init \
	bn_mp_init_copy \
	bn_mp_init_i32 \
	bn_mp_init_i64 \
	bn_mp_init_l \
	bn_mp_init_ll \
	bn_mp_init_multi \
	bn_mp_init_set \
	bn_mp_init_size \
	bn_mp_init_u32 \
	bn_mp_init_u64 \
	bn_mp_init_ul \
	bn_mp_init_ull \
	bn_mp_invmod \
	bn_mp_iseven \
	bn_mp_isodd \
	bn_mp_is_square \
	bn_mp_kronecker \
	bn_mp_lcm \
	bn_mp_log_u32 \
	bn_mp_lshd \
	bn_mp_mod_2d \
	bn_mp_mod \
	bn_mp_mod_d \
	bn_mp_montgomery_calc_normalization \
	bn_mp_montgomery_reduce \
	bn_mp_montgomery_setup \
	bn_mp_mul_2 \
	bn_mp_mul_2d \
	bn_mp_mul \
	bn_mp_mul_d \
	bn_mp_mulmod \
	bn_mp_neg \
	bn_mp_or \
	bn_mp_pack \
	bn_mp_pack_count \
	bn_mp_prime_fermat \
	bn_mp_prime_frobenius_underwood \
	bn_mp_prime_miller_rabin \
	bn_mp_prime_rabin_miller_trials \
	bn_mp_prime_strong_lucas_selfridge \
	bn_mp_radix_size \
	bn_mp_radix_smap \
	bn_mp_read_radix \
	bn_mp_reduce_2k \
	bn_mp_reduce_2k_l \
	bn_mp_reduce_2k_setup \
	bn_mp_reduce_2k_setup_l \
	bn_mp_reduce \
	bn_mp_reduce_is_2k \
	bn_mp_reduce_is_2k_l \
	bn_mp_reduce_setup \
	bn_mp_root_u32 \
	bn_mp_rshd \
	bn_mp_sbin_size \
	bn_mp_set \
	bn_mp_set_i32 \
	bn_mp_set_i64 \
	bn_mp_set_l \
	bn_mp_set_ll \
	bn_mp_set_u32 \
	bn_mp_set_u64 \
	bn_mp_set_ul \
	bn_mp_set_ull \
	bn_mp_shrink \
	bn_mp_signed_rsh \
	bn_mp_sqr \
	bn_mp_sqrmod \
	bn_mp_sqrt \
	bn_mp_sqrtmod_prime \
	bn_mp_sub \
	bn_mp_sub_d \
	bn_mp_submod \
	bn_mp_to_radix \
	bn_mp_to_sbin \
	bn_mp_to_ubin \
	bn_mp_ubin_size \
	bn_mp_unpack \
	bn_mp_xor \
	bn_mp_zero \
	bn_prime_tab \
	bn_s_mp_add \
	bn_s_mp_balance_mul \
	bn_s_mp_exptmod \
	bn_s_mp_exptmod_fast \
	bn_s_mp_get_bit \
	bn_s_mp_invmod_fast \
	bn_s_mp_invmod_slow \
	bn_s_mp_karatsuba_mul \
	bn_s_mp_karatsuba_sqr \
	bn_s_mp_montgomery_reduce_fast \
	bn_s_mp_mul_digs \
	bn_s_mp_mul_digs_fast \
	bn_s_mp_mul_high_digs \
	bn_s_mp_mul_high_digs_fast \
	bn_s_mp_prime_is_divisible \
	bn_s_mp_reverse \
	bn_s_mp_sqr \
	bn_s_mp_sqr_fast \
	bn_s_mp_sub \
	bn_s_mp_toom_mul \
	bn_s_mp_toom_sqr

WASM_CFLAGS = \
	--compile \
	--optimize=s \
	--sysroot=$(SYSROOT) \
	--target=wasm32-wasi \
	-DMP_32BIT \
	-DMP_NO_FILE \
	-ffreestanding \
	-fno-builtin \
	-fpic

WASM_LDFLAGS = \
	--allow-undefined \
	--no-entry \
	--relocatable

.PHONY: all
all: $(TARGET_TARBALL)

$(TARGET_TARBALL): $(TARGET_RELEASE)/include/tommath.h $(TARGET_RELEASE)/lib/libtommath.a
	tar -C $(TARGET_DIR) -c -f $@ $(RELEASE)

$(TARGET_RELEASE)/include/tommath.h: $(TARGET_RELEASE)/include
	cp $(SOURCE_DIR)/tommath.h $@

$(TARGET_RELEASE)/include:
	mkdir -p $@

$(TARGET_RELEASE)/lib/libtommath.a: $(SOURCE_FILES:%=$(TARGET_OBJECTS)/%.o) | $(TARGET_RELEASE)/lib
	$(WASM_LD) $(WASM_LDFLAGS) -o $@ $+

$(TARGET_RELEASE)/lib:
	mkdir -p $@

$(TARGET_OBJECTS)/%.o: $(SOURCE_DIR)/%.c | $(TARGET_OBJECTS)
	$(WASM_CC) $(WASM_CFLAGS) -o $@ $<

$(TARGET_OBJECTS):
	mkdir -p $@

.PHONY: clean
clean:
	rm -f -r $(TARGET_DIR)
