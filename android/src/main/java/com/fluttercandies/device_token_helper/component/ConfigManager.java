package com.fluttercandies.device_token_helper.component;

public class ConfigManager {
    private boolean redBadge;//是否使用红点通道

    public static ConfigManager getInstant() {
        return ConfigManagerHolder.configManager;
    }

    public boolean isRedBadge() {
        return redBadge;
    }

    public void setRedBadge(boolean redBadge) {
        this.redBadge = redBadge;
    }

    private static class ConfigManagerHolder {
        private static ConfigManager configManager = new ConfigManager();
    }
}
