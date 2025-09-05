import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/workout_provider.dart';

/// Statistics and records screen
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _intensitySelectedDays = 7; // 强度图表选择的天数
  int _moodSelectedDays = 7; // 心情图表选择的天数
  
  // 时间范围选项
  final List<Map<String, dynamic>> _timeRangeOptions = [
    {'label': '7', 'days': 7},
    {'label': '14', 'days': 14},
    {'label': '30', 'days': 30},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }
  
  /// 加载初始数据
  void _loadInitialData() {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    workoutProvider.loadStats();
    workoutProvider.loadRecentRecords();
    workoutProvider.loadIntensityTrend(days: _intensitySelectedDays);
    workoutProvider.loadMoodCorrelationTrend(days: _moodSelectedDays);
  }
  
  /// 切换强度图时间范围
  void _onIntensityTimeRangeChanged(int days) {
    if (_intensitySelectedDays != days) {
      setState(() {
        _intensitySelectedDays = days;
      });
      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      workoutProvider.loadIntensityTrend(days: days);
    }
  }
  
  /// 切换心情图时间范围
  void _onMoodTimeRangeChanged(int days) {
    if (_moodSelectedDays != days) {
      setState(() {
        _moodSelectedDays = days;
      });
      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      workoutProvider.loadMoodCorrelationTrend(days: days);
    }
  }

  /// Get workout intensity data from API
  List<FlSpot> _getWorkoutIntensityData(WorkoutProvider provider) {
    if (provider.intensityTrend?.intensityData == null) {
      return []; // Return empty if no data
    }
    
    // Filter out null values - API already returns correct number of days
    return provider.intensityTrend!.intensityData
        .where((data) => data.intensityScore != null)
        .map((data) => FlSpot(data.dayIndex.toDouble(), data.intensityScore!))
        .toList();
  }

  /// Get mood correlation data from API
  List<FlSpot> _getMoodCorrelationData(WorkoutProvider provider) {
    if (provider.moodCorrelationTrend?.correlationData == null) {
      return []; // Return empty if no data
    }
    
    // Filter out null values - API already returns correct number of days
    return provider.moodCorrelationTrend!.correlationData
        .where((data) => data.improvementScore != null)
        .map((data) => FlSpot(data.dayIndex.toDouble(), data.improvementScore!))
        .toList();
  }

  /// Get day labels for intensity chart
  List<String> _getIntensityDayLabels(WorkoutProvider provider) {
    if (provider.intensityTrend?.intensityData != null) {
      return provider.intensityTrend!.intensityData
          .take(_intensitySelectedDays)
          .map((data) => _formatDateToLabel(data.date, _intensitySelectedDays))
          .toList();
    }
    
    // Fallback to generating labels based on selected time range
    final now = DateTime.now();
    final days = <String>[];
    for (int i = _intensitySelectedDays - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      days.add(_formatDateToLabel(date.toIso8601String().substring(0, 10), _intensitySelectedDays));
    }
    return days;
  }
  
  /// Get day labels for mood chart
  List<String> _getMoodDayLabels(WorkoutProvider provider) {
    if (provider.moodCorrelationTrend?.correlationData != null) {
      return provider.moodCorrelationTrend!.correlationData
          .take(_moodSelectedDays)
          .map((data) => _formatDateToLabel(data.date, _moodSelectedDays))
          .toList();
    }
    
    // Fallback to generating labels based on selected time range
    final now = DateTime.now();
    final days = <String>[];
    for (int i = _moodSelectedDays - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      days.add(_formatDateToLabel(date.toIso8601String().substring(0, 10), _moodSelectedDays));
    }
    return days;
  }

  /// Format date string to appropriate label based on time range
  String _formatDateToLabel(String dateString, int selectedDays) {
    try {
      final date = DateTime.parse(dateString);
      if (selectedDays == 7) {
        // 7天显示星期缩写
        return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
      } else {
        // 15天和30天显示月/日
        return '${date.month}/${date.day}';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  /// Build no data widget
  Widget _buildNoDataWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 48,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete more workouts to see your progress!',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build insufficient data widget for when we have some data but not enough for a good chart
  Widget _buildInsufficientDataWidget(String message, int dataPoints) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Data points: $dataPoints\nComplete more workouts for better insights!',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build intensity chart widget
  Widget _buildIntensityChart(WorkoutProvider workoutProvider) {
    final intensityData = _getWorkoutIntensityData(workoutProvider);
    
    if (intensityData.isEmpty) {
      return _buildNoDataWidget('No intensity data available');
    } else if (intensityData.length == 1) {
      return _buildInsufficientDataWidget('Limited intensity data', intensityData.length);
    }
    
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (_intensitySelectedDays - 1).toDouble(),
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: intensityData,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.primaryDark,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: AppColors.white,
                );
              },
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final days = _getIntensityDayLabels(workoutProvider);
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Text(
                    days[value.toInt()],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.divider,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  /// Build mood correlation chart widget
  Widget _buildMoodChart(WorkoutProvider workoutProvider) {
    final moodData = _getMoodCorrelationData(workoutProvider);
    
    if (moodData.isEmpty) {
      return _buildNoDataWidget('No mood correlation data available');
    } else if (moodData.length == 1) {
      return _buildInsufficientDataWidget('Limited mood data', moodData.length);
    }
    
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (_moodSelectedDays - 1).toDouble(),
        minY: 0,
        maxY: 5,
        lineBarsData: [
          LineChartBarData(
            spots: moodData,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppColors.secondary.withOpacity(0.8),
                AppColors.success,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.secondary.withOpacity(0.2),
                  AppColors.secondary.withOpacity(0.03),
                ],
              ),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.secondary,
                  strokeWidth: 2,
                  strokeColor: AppColors.white,
                );
              },
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final days = _getMoodDayLabels(workoutProvider);
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Text(
                    days[value.toInt()],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.divider,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Workout Records'),
        centerTitle: true,
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
          if (workoutProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // This week overview card
                if (workoutProvider.stats != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This Week Overview',
                          style: AppTextStyles.h5.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                'Workout Days',
                                '${workoutProvider.stats!.thisWeek.workouts}',
                                'days',
                                AppColors.white,
                              ),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                'Total Duration',
                                '${workoutProvider.stats!.thisWeek.duration}',
                                'minutes',
                                AppColors.white,
                              ),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                'Mood Improvement',
                                workoutProvider.stats!.moodImprovementRate.toStringAsFixed(0),
                                '%',
                                AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
                
                // Workout Intensity Trend Chart
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Workout Intensity Trend',
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Past $_intensitySelectedDays days average intensity',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          _buildTimeRangeSelector(_intensitySelectedDays, _onIntensityTimeRangeChanged),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: _buildIntensityChart(workoutProvider),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Mood & Exercise Correlation Chart
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.psychology,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Mood & Exercise Correlation',
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily mood improvement',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          _buildTimeRangeSelector(_moodSelectedDays, _onMoodTimeRangeChanged),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: _buildMoodChart(workoutProvider),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // History records
                const Text(
                  'Recent Workouts',
                  style: AppTextStyles.h5,
                ),
                const SizedBox(height: 16),
                
                if (workoutProvider.recentRecords.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 64,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No workout records yet',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  )
                else
                  ...workoutProvider.recentRecords.map((record) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.getCompletionRateColor(record.completionRate).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              Icons.fitness_center,
                              color: AppColors.getCompletionRateColor(record.completionRate),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.statusText,
                                  style: AppTextStyles.labelMedium,
                                ),
                                Text(
                                  'Completion Rate: ${record.completionRateText}',
                                  style: AppTextStyles.bodySmall,
                                ),
                                if (record.actualDuration != null)
                                  Text(
                                    'Duration: ${record.actualDurationText}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            record.completionRateText,
                            style: AppTextStyles.numberSmall.copyWith(
                              color: AppColors.getCompletionRateColor(record.completionRate),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
  
  /// 构建时间范围选择器
  Widget _buildTimeRangeSelector(int selectedDays, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _timeRangeOptions.map((option) {
          final isSelected = selectedDays == option['days'];
          return GestureDetector(
            onTap: () => onChanged(option['days']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                option['label'],
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTextStyles.numberMedium.copyWith(color: color),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: AppTextStyles.bodySmall.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: color.withOpacity(0.9)),
        ),
      ],
    );
  }
}