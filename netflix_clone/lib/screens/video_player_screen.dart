import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/movie.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Movie movie;

  const VideoPlayerScreen({super.key, required this.movie});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = false;

  // -------------------------------------------------------------
  // DEMO VIDEO URLs
  // -------------------------------------------------------------

  static const String beeVideo =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  static const String butterflyVideo =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  @override
  void initState() {
    super.initState();

    // Alternate demo videos based on movie title.
    final String videoUrl = _getVideoUrl();

    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    _controller.addListener(_videoListener);

    _initializeVideo();
  }

  // -------------------------------------------------------------
  // SELECT DEMO VIDEO
  // -------------------------------------------------------------

  String _getVideoUrl() {
    final title = widget.movie.title.toLowerCase();

    const butterflyMovies = [
      'money heist',
      'avatar',
      'interstellar',
      'joker',
      'spider-man: no way home',
      'the dark knight',
      'dune',
      'oppenheimer',
      'black panther',
      'the batman',
    ];

    for (final movieTitle in butterflyMovies) {
      if (title.contains(movieTitle)) {
        return butterflyVideo;
      }
    }

    return beeVideo;
  }

  // -------------------------------------------------------------
  // INITIALIZE VIDEO
  // -------------------------------------------------------------

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });

      await _controller.play();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
      });
    }
  }

  // -------------------------------------------------------------
  // VIDEO LISTENER
  // -------------------------------------------------------------

  void _videoListener() {
    if (!mounted) return;

    setState(() {});
  }

  // -------------------------------------------------------------
  // PLAY / PAUSE
  // -------------------------------------------------------------

  Future<void> _togglePlayPause() async {
    if (!_isInitialized) return;

    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      await _controller.play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  // -------------------------------------------------------------
  // SEEK BACKWARD
  // -------------------------------------------------------------

  Future<void> _rewind() async {
    if (!_isInitialized) return;

    final currentPosition = _controller.value.position;

    final newPosition = currentPosition - const Duration(seconds: 10);

    await _controller.seekTo(
      newPosition < Duration.zero ? Duration.zero : newPosition,
    );
  }

  // -------------------------------------------------------------
  // SEEK FORWARD
  // -------------------------------------------------------------

  Future<void> _forward() async {
    if (!_isInitialized) return;

    final currentPosition = _controller.value.position;
    final duration = _controller.value.duration;

    final newPosition = currentPosition + const Duration(seconds: 10);

    await _controller.seekTo(newPosition > duration ? duration : newPosition);
  }

  // -------------------------------------------------------------
  // MUTE / UNMUTE
  // -------------------------------------------------------------

  Future<void> _toggleMute() async {
    if (!_isInitialized) return;

    if (_isMuted) {
      await _controller.setVolume(1.0);
    } else {
      await _controller.setVolume(0.0);
    }

    if (mounted) {
      setState(() {
        _isMuted = !_isMuted;
      });
    }
  }

  // -------------------------------------------------------------
  // FORMAT DURATION
  // -------------------------------------------------------------

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // -------------------------------------------------------------
  // DISPOSE
  // -------------------------------------------------------------

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,

        title: Text(
          widget.movie.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: _buildBody(),
    );
  }

  // -------------------------------------------------------------
  // BODY
  // -------------------------------------------------------------

  Widget _buildBody() {
    if (_hasError) {
      return _buildError();
    }

    if (!_isInitialized) {
      return _buildLoading();
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildVideoPlayer(),

            const SizedBox(height: 20),

            _buildMovieInformation(),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // LOADING
  // -------------------------------------------------------------

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.red),
          SizedBox(height: 20),
          Text(
            'Loading video...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // ERROR
  // -------------------------------------------------------------

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 70),

            const SizedBox(height: 20),

            const Text(
              'Unable to play video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isInitialized = false;
                });

                _initializeVideo();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // VIDEO PLAYER
  // -------------------------------------------------------------

  Widget _buildVideoPlayer() {
    return Container(
      width: double.infinity,
      color: Colors.black,

      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,

        child: Stack(
          children: [
            // -----------------------------------------------------
            // VIDEO
            // -----------------------------------------------------

            Positioned.fill(child: VideoPlayer(_controller)),

            // -----------------------------------------------------
            // DARK GRADIENT
            // -----------------------------------------------------
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // -----------------------------------------------------
            // CENTER CONTROLS
            // -----------------------------------------------------
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // REWIND
                  IconButton(
                    onPressed: _rewind,
                    iconSize: 45,
                    color: Colors.white,
                    tooltip: 'Back 10 seconds',
                    icon: const Icon(Icons.replay_10),
                  ),

                  const SizedBox(width: 20),

                  // PLAY / PAUSE
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),

                    child: IconButton(
                      onPressed: _togglePlayPause,
                      iconSize: 58,
                      color: Colors.white,
                      tooltip: 'Play / Pause',
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // FORWARD
                  IconButton(
                    onPressed: _forward,
                    iconSize: 45,
                    color: Colors.white,
                    tooltip: 'Forward 10 seconds',
                    icon: const Icon(Icons.forward_10),
                  ),
                ],
              ),
            ),

            // -----------------------------------------------------
            // MOVIE TITLE
            // -----------------------------------------------------
            Positioned(
              top: 15,
              left: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  widget.movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // -----------------------------------------------------
            // MUTE BUTTON
            // -----------------------------------------------------
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _toggleMute,
                  color: Colors.white,
                  icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
                ),
              ),
            ),

            // -----------------------------------------------------
            // BOTTOM PROGRESS AREA
            // -----------------------------------------------------
            Positioned(
              left: 12,
              right: 12,
              bottom: 5,
              child: Column(
                children: [
                  VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    colors: const VideoProgressColors(
                      playedColor: Colors.red,
                      bufferedColor: Colors.white54,
                      backgroundColor: Colors.white24,
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_controller.value.position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDuration(_controller.value.duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // MOVIE INFORMATION
  // -------------------------------------------------------------

  Widget _buildMovieInformation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.movie.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                widget.movie.year,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(width: 12),

              const Text('•', style: TextStyle(color: Colors.white54)),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  widget.movie.genre,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),

              const SizedBox(width: 5),

              Text(
                widget.movie.rating.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            widget.movie.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
