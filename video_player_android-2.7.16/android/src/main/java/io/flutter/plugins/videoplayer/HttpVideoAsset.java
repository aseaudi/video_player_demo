// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.OptIn;
import androidx.annotation.VisibleForTesting;
import androidx.media3.common.MediaItem;
import androidx.media3.common.MimeTypes;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.datasource.DataSource;
import androidx.media3.datasource.DefaultDataSource;
import androidx.media3.datasource.DefaultHttpDataSource;
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.common.util.Log;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.database.DatabaseProvider;
import androidx.media3.database.StandaloneDatabaseProvider;
import androidx.media3.datasource.DataSource;
import androidx.media3.datasource.DefaultDataSource;
import androidx.media3.datasource.DefaultHttpDataSource;
import androidx.media3.datasource.HttpEngineDataSource;
import androidx.media3.datasource.cache.Cache;
import androidx.media3.datasource.cache.CacheDataSink;
import androidx.media3.datasource.cache.CacheDataSource;
import androidx.media3.datasource.cache.NoOpCacheEvictor;
import androidx.media3.datasource.cache.SimpleCache;
// import androidx.media3.datasource.cronet.CronetDataSource;
// import androidx.media3.datasource.cronet.CronetUtil;
import androidx.media3.exoplayer.DefaultRenderersFactory;
import androidx.media3.exoplayer.RenderersFactory;
import androidx.media3.exoplayer.offline.DownloadManager;
import androidx.media3.exoplayer.offline.DownloadNotificationHelper;

import java.io.File;
import java.util.Map;

final class HttpVideoAsset extends VideoAsset {
  private static final String DEFAULT_USER_AGENT = "ExoPlayer";
  private static final String HEADER_USER_AGENT = "User-Agent";

  @NonNull private final StreamingFormat streamingFormat;
  @NonNull private final Map<String, String> httpHeaders;
  private static DatabaseProvider databaseProvider;
  private static Cache downloadCache;
  private static File downloadDirectory;

  HttpVideoAsset(
      @Nullable String assetUrl,
      @NonNull StreamingFormat streamingFormat,
      @NonNull Map<String, String> httpHeaders) {
    super(assetUrl);
    this.streamingFormat = streamingFormat;
    this.httpHeaders = httpHeaders;
  }

  @NonNull
  @Override
  MediaItem getMediaItem() {
    MediaItem.Builder builder = new MediaItem.Builder().setUri(assetUrl);
    String mimeType = null;
    switch (streamingFormat) {
      case SMOOTH:
        mimeType = MimeTypes.APPLICATION_SS;
        break;
      case DYNAMIC_ADAPTIVE:
        mimeType = MimeTypes.APPLICATION_MPD;
        break;
      case HTTP_LIVE:
        mimeType = MimeTypes.APPLICATION_M3U8;
        break;
    }
    if (mimeType != null) {
      builder.setMimeType(mimeType);
    }
    return builder.build();
  }

  @Override
  MediaSource.Factory getMediaSourceFactory(Context context) {
    return getMediaSourceFactory(context, new DefaultHttpDataSource.Factory());
  }

  /**
   * Returns a configured media source factory, starting at the provided factory.
   *
   * <p>This method is provided for ease of testing without making real HTTP calls.
   *
   * @param context application context.
   * @param initialFactory initial factory, to be configured.
   * @return configured factory, or {@code null} if not needed for this asset type.
   */
  @VisibleForTesting
  MediaSource.Factory getMediaSourceFactory(
      Context context, DefaultHttpDataSource.Factory initialFactory) {
    String userAgent = DEFAULT_USER_AGENT;
    if (!httpHeaders.isEmpty() && httpHeaders.containsKey(HEADER_USER_AGENT)) {
      userAgent = httpHeaders.get(HEADER_USER_AGENT);
    }
    unstableUpdateDataSourceFactory(initialFactory, httpHeaders, userAgent);
    DataSource.Factory dataSourceFactory1 = new DefaultDataSource.Factory(context, initialFactory);
    DataSource.Factory dataSourceFactory = buildReadOnlyCacheDataSource(dataSourceFactory1, getDownloadCache(context));
    return new DefaultMediaSourceFactory(context).setDataSourceFactory(dataSourceFactory);
  }

  private static synchronized Cache getDownloadCache(Context context) {
    if (downloadCache == null) {
      File downloadContentDirectory =
          new File(getDownloadDirectory(context), "downloads");
      downloadCache =
          new SimpleCache(
              downloadContentDirectory, new NoOpCacheEvictor(), getDatabaseProvider(context));
    }
    return downloadCache;
  }

  private static synchronized DatabaseProvider getDatabaseProvider(Context context) {
    if (databaseProvider == null) {
      databaseProvider = new StandaloneDatabaseProvider(context);
    }
    return databaseProvider;
  }

  private static synchronized File getDownloadDirectory(Context context) {
    if (downloadDirectory == null) {
      downloadDirectory = context.getExternalFilesDir(/* type= */ null);
      if (downloadDirectory == null) {
        downloadDirectory = context.getFilesDir();
      }
    }
    return downloadDirectory;
  }

  private static CacheDataSource.Factory buildReadOnlyCacheDataSource(
      DataSource.Factory upstreamFactory, Cache cache) {
    return new CacheDataSource.Factory()
        .setCache(cache)
        .setUpstreamDataSourceFactory(upstreamFactory)
        // .setCacheWriteDataSinkFactory(null)
        .setCacheWriteDataSinkFactory(
            new CacheDataSink.Factory()
                .setCache(cache)
                .setFragmentSize(CacheDataSink.DEFAULT_FRAGMENT_SIZE)
        )
        .setFlags(CacheDataSource.FLAG_IGNORE_CACHE_ON_ERROR);
  }


  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  @OptIn(markerClass = UnstableApi.class)
  private static void unstableUpdateDataSourceFactory(
      @NonNull DefaultHttpDataSource.Factory factory,
      @NonNull Map<String, String> httpHeaders,
      @Nullable String userAgent) {
    factory.setUserAgent(userAgent).setAllowCrossProtocolRedirects(true);
    if (!httpHeaders.isEmpty()) {
      factory.setDefaultRequestProperties(httpHeaders);
    }
  }
}
