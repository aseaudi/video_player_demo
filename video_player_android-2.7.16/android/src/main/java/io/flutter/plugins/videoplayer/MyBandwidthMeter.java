package io.flutter.plugins.videoplayer;

import android.os.Handler;
import androidx.annotation.Nullable;
import androidx.media3.common.util.Log;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.datasource.DataSource;
import androidx.media3.datasource.DataSpec;
import androidx.media3.datasource.TransferListener;
import androidx.media3.exoplayer.upstream.BandwidthMeter;
import androidx.media3.exoplayer.upstream.DefaultBandwidthMeter;

@UnstableApi public class MyBandwidthMeter implements BandwidthMeter, TransferListener {

  private int totalBytesTransferred = 0;
  private int oldTotalBytesTransferred = 0;

  @Override
  public void onTransferInitializing(DataSource source, DataSpec dataSpec, boolean isNetwork) {
    // Log.d("XXXX", "MyBandwithMeter onTransferInitializing sourceUri " + source.getUri().toString());
  }

  @Override
  public void onTransferStart(DataSource source, DataSpec dataSpec, boolean isNetwork) {
    // Log.d("XXXX", "MyBandwithMeter onTransferStart sourceUri " + source.getUri().toString());

  }

  @Override
  public void onBytesTransferred(DataSource source, DataSpec dataSpec, boolean isNetwork,
      int bytesTransferred) {
        if (isNetwork) {
        totalBytesTransferred += bytesTransferred;
        if (totalBytesTransferred - oldTotalBytesTransferred > 100000) {
            // Log.d("XXXX", "MyBandwithMeter onBytesTransferred sourceUri %s %d " + source.getUri().toString() + " totalBytesTransferred {%d}" + totalBytesTransferred);
            Log.d("XXXX", String.format("MyBandwithMeter onBytesTransferred sourceUri %s totalBytesTransferred %,d", source.getUri().toString(), totalBytesTransferred));
            oldTotalBytesTransferred = totalBytesTransferred;
        }
    }
  }

  @Override
  public void onTransferEnd(DataSource source, DataSpec dataSpec, boolean isNetwork) {
    // Log.d("XXXX", "MyBandwithMeter onTransferEnd ");
    totalBytesTransferred = 0;
    oldTotalBytesTransferred = 0;
  }

  @Override
  public long getBitrateEstimate() {
    return 0;
  }

  @Nullable
  @Override
  public TransferListener getTransferListener() {
    return this;
  }

  @Override
  public void addEventListener(Handler eventHandler, EventListener eventListener) {

  }

  @Override
  public void removeEventListener(EventListener eventListener) {

  }
}
