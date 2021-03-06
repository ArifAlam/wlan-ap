/* SPDX-License-Identifier: BSD-3-Clause */

#ifndef _VIF_H__
#define _VIF_H__

#define OVSDB_SECURITY_KEY                  "key"
#define OVSDB_SECURITY_OFTAG                "oftag"
#define OVSDB_SECURITY_MODE                 "mode"
#define OVSDB_SECURITY_MODE_WEP64           "64"
#define OVSDB_SECURITY_MODE_WEP128          "128"
#define OVSDB_SECURITY_MODE_WPA1            "1"
#define OVSDB_SECURITY_MODE_WPA2            "2"
#define OVSDB_SECURITY_MODE_WPA3            "3"
#define OVSDB_SECURITY_MODE_MIXED           "mixed"
#define OVSDB_SECURITY_ENCRYPTION           "encryption"
#define OVSDB_SECURITY_ENCRYPTION_OPEN      "OPEN"
#define OVSDB_SECURITY_ENCRYPTION_WEP       "WEP"
#define OVSDB_SECURITY_ENCRYPTION_WPA_PSK   "WPA-PSK"
#define OVSDB_SECURITY_ENCRYPTION_WPA_SAE   "WPA-SAE"
#define OVSDB_SECURITY_ENCRYPTION_WPA_EAP   "WPA-EAP"
#define OVSDB_SECURITY_ENCRYPTION_WPA3_EAP  "WPA3-EAP"
#define OVSDB_SECURITY_RADIUS_SERVER_IP     "radius_server_ip"
#define OVSDB_SECURITY_RADIUS_SERVER_PORT   "radius_server_port"
#define OVSDB_SECURITY_RADIUS_SERVER_SECRET "radius_server_secret"
#define OVSDB_SECURITY_RADIUS_ACCT_IP       "radius_acct_ip"
#define OVSDB_SECURITY_RADIUS_ACCT_PORT     "radius_acct_port"
#define OVSDB_SECURITY_RADIUS_ACCT_SECRET   "radius_acct_secret"
#define OVSDB_SECURITY_RADIUS_ACCT_INTERVAL "radius_acct_interval"

#define SCHEMA_CONSTS_RADIUS_NAS_ID         "radius_nas_id"
#define SCHEMA_CONSTS_RADIUS_OPER_NAME      "radius_oper_name"
#define SCHEMA_CONSTS_RADIUS_NAS_IP         "radius_nas_ip"

bool vif_get_security(struct schema_Wifi_VIF_State *vstate, char *mode, char *encryption, char *radiusServerIP, char *password, char *port);
extern bool vif_state_update(struct uci_section *s, struct schema_Wifi_VIF_Config *vconf);
void vif_hs20_update(struct schema_Hotspot20_Config *hs2conf);
void vif_hs20_osu_update(struct schema_Hotspot20_OSU_Providers *hs2osuconf);
void vif_hs20_icon_update(struct schema_Hotspot20_Icon_Config *hs2iconconf);
void vif_section_del(char *section_name);
void vif_check_radius_proxy(void);

#endif
