import argparse
import os
import pandas as pd
from mcap_ros2.reader import read_ros2_messages
from rosbag2_py import SequentialReader, StorageOptions, ConverterOptions
from rclpy.serialization import deserialize_message
from rosidl_runtime_py.utilities import get_message

def read_mcap(bag_path):
    data = []
    for msg in read_ros2_messages(bag_path):
        data.append({
            'timestamp': msg.log_time,
            'topic': msg.channel.topic,
            'message': msg.ros_msg
        })
    return data

def read_sqlite(bag_path):
    storage_options = StorageOptions(uri=bag_path, storage_id='sqlite3')
    converter_options = ConverterOptions('', '')
    reader = SequentialReader()
    reader.open(storage_options, converter_options)
    topics = reader.get_all_topics_and_types()
    data = []
    while reader.has_next():
        topic, msg, t = reader.read_next()
        msg_type = get_message(next(t.type for t in topics if t.name == topic))
        ros_msg = deserialize_message(msg, msg_type)
        data.append({
            'timestamp': t,
            'topic': topic,
            'message': ros_msg
        })
    return data

def write_csv(data, output_file):
    df = pd.DataFrame(data)
    df.to_csv(output_file, index=False)

def main():
    parser = argparse.ArgumentParser(description='Convert ROS2 bag to CSV.')
    parser.add_argument('bag_path', help='Path to the ROS2 bag file.')
    parser.add_argument('output_file', help='Path to save the CSV file.')
    args = parser.parse_args()

    if args.bag_path.endswith('.mcap'):
        data = read_mcap(args.bag_path)
    elif args.bag_path.endswith('.db3'):
        data = read_sqlite(args.bag_path)
    else:
        raise ValueError('Unsupported bag file format.')

    write_csv(data, args.output_file)

if __name__ == '__main__':
    main()
